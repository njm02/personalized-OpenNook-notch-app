import Foundation
import Combine

enum WidgetScreen: String { case home, calendar, music, focus }

enum CompactLiveMode: Equatable {
    case idle, music, focus

    static func resolve(screen: WidgetScreen, musicPlaying: Bool, timerRunning: Bool) -> Self {
        switch screen {
        case .music: return musicPlaying ? .music : .idle
        case .focus: return timerRunning ? .focus : .idle
        case .home, .calendar: return .idle
        }
    }
}

/// Session state survives the expanded view being removed when the notch collapses.
@MainActor
final class WidgetStore: ObservableObject {
    static let shared = WidgetStore()
    @Published var selectedScreen: WidgetScreen = .calendar {
        didSet { liveModeChanged?(timerIsRunning) }
    }

    func compactMode(musicPlaying: Bool) -> CompactLiveMode {
        .resolve(screen: selectedScreen, musicPlaying: musicPlaying, timerRunning: timerIsRunning)
    }
    @Published private(set) var timerDeadline: Date? {
        didSet { scheduleCompletion() }
    }
    @Published private(set) var timerIsRunning = false
    var liveModeChanged: ((Bool) -> Void)?
    private var completionTask: Task<Void, Never>?
    @Published private(set) var pausedSeconds: TimeInterval = 1500
    @Published private(set) var timerDuration: TimeInterval = 1500

    private func scheduleCompletion() {
        completionTask?.cancel()
        let active = timerDeadline.map { $0 > .now } ?? false
        if active != timerIsRunning {
            timerIsRunning = active
            liveModeChanged?(active)
        }
        guard let deadline = timerDeadline else { return }
        completionTask = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(max(0, deadline.timeIntervalSinceNow))) }
            catch { return }
            guard let self, self.timerDeadline == deadline else { return }
            self.pausedSeconds = 0
            self.timerDeadline = nil
        }
    }

    func addFiveMinutes(at date: Date = .now) {
        let left = remaining(at: date)
        if timerDeadline != nil && left > 0 { timerDeadline = date.addingTimeInterval(left + 300) }
        else { pausedSeconds = left + 300; timerDeadline = nil }
        timerDuration += 300
    }

    func remaining(at date: Date) -> TimeInterval {
        max(0, timerDeadline.map { $0.timeIntervalSince(date) } ?? pausedSeconds)
    }

    func toggleTimer(at date: Date = .now) {
        if timerDeadline != nil, remaining(at: date) > 0 {
            pausedSeconds = remaining(at: date)
            timerDeadline = nil
        } else {
            let seconds = remaining(at: date) > 0 ? remaining(at: date) : timerDuration
            pausedSeconds = seconds
            timerDeadline = date.addingTimeInterval(seconds)
        }
    }

    @discardableResult
    func setTimerDuration(_ input: String) -> Bool {
        guard let duration = FocusDuration.seconds(from: input) else { return false }
        timerDeadline = nil
        timerDuration = duration
        pausedSeconds = duration
        return true
    }

    func resetTimer(minutes: Int? = nil) {
        if let minutes { timerDuration = TimeInterval(minutes * 60) }
        pausedSeconds = timerDuration
        timerDeadline = nil
    }
}
