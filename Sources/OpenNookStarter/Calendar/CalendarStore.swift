import AppKit
import Combine
import EventKit

struct CalendarChoice: Identifiable {
    let id: String
    let title: String
    let account: String
    var label: String { "\(title) — \(account)" }
}

struct AgendaEvent: Identifiable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let isAllDay: Bool
    let location: String?
}

/// Local EventKit access only. This type never saves or deletes calendar events.
@MainActor
final class CalendarStore: ObservableObject {
    static let shared = CalendarStore()
    private let eventStore = EKEventStore()
    private let defaults = UserDefaults.standard
    private let selectionKey = "personalnotch.calendar.selectedID"
    private var subscriptions = Set<AnyCancellable>()

    @Published private(set) var selectedDay = Date.now
    @Published private(set) var displayedMonth = Date.now
    @Published private(set) var authorization = EKEventStore.authorizationStatus(for: .event)
    @Published private(set) var calendars: [CalendarChoice] = []
    @Published private(set) var events: [AgendaEvent] = []
    @Published private(set) var selectedID: String
    @Published private(set) var requestingAccess = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastRefresh: Date?

    var hasUsageDescription: Bool {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "NSCalendarsFullAccessUsageDescription") as? String else { return false }
        return !value.isEmpty
    }
    var selectedCalendar: CalendarChoice? { calendars.first { $0.id == selectedID } }
    var selectionUnavailable: Bool { !selectedID.isEmpty && selectedCalendar == nil }

    init() {
        selectedID = defaults.string(forKey: selectionKey) ?? ""
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .merge(with: NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification))
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in self?.refresh() }
            }
            .store(in: &subscriptions)
    }

    func connect() async {
        guard !requestingAccess else { return }
        guard hasUsageDescription else {
            errorMessage = "Launch the bundled OpenNookStarter.app to connect your calendar."
            return
        }
        requestingAccess = true
        errorMessage = nil
        defer { requestingAccess = false }
        do {
            _ = try await eventStore.requestFullAccessToEvents()
        } catch {
            // Avoid exposing event/account details through error logs or diagnostics.
            errorMessage = "Calendar access could not be requested. Try again or check System Settings."
        }
        refresh()
    }

    func select(_ id: String) {
        selectedID = id
        if id.isEmpty { defaults.removeObject(forKey: selectionKey) }
        else { defaults.set(id, forKey: selectionKey) }
        refresh()
    }

    func chooseDay(_ date: Date) { selectedDay = date }
    func moveMonth(_ amount: Int) {
        let start = Calendar.current.dateInterval(of: .month, for: displayedMonth)!.start
        guard let date = Calendar.current.date(byAdding: .month, value: amount, to: start) else { return }
        displayedMonth = date
        selectedDay = date
        refresh()
    }
    func showToday() { displayedMonth = .now; selectedDay = .now; refresh() }
    func events(on date: Date) -> [AgendaEvent] {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return events.filter { $0.start < end && ($0.end > start || ($0.end == $0.start && $0.start >= start)) }
    }

    func refresh(now: Date = .now) {
        authorization = EKEventStore.authorizationStatus(for: .event)
        guard authorization == .fullAccess else {
            calendars = []
            events = []
            lastRefresh = nil
            return
        }
        errorMessage = nil
        let available = eventStore.calendars(for: .event)
        calendars = available.map {
            CalendarChoice(id: $0.calendarIdentifier, title: $0.title, account: $0.source.title)
        }.sorted { $0.label.localizedStandardCompare($1.label) == .orderedAscending }
        guard let selected = available.first(where: { $0.calendarIdentifier == selectedID }) else {
            events = []
            lastRefresh = now
            return
        }
        let start = Calendar.current.dateInterval(of: .month, for: displayedMonth)!.start
        guard let end = Calendar.current.date(byAdding: .month, value: 1, to: start) else { return }
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: [selected])
        events = eventStore.events(matching: predicate)
            .filter { $0.status != .canceled }
            .sorted { $0.startDate < $1.startDate }
            .map {
                AgendaEvent(
                    id: "\($0.calendarItemIdentifier)-\($0.startDate.timeIntervalSince1970)",
                    title: ($0.title?.isEmpty == false ? $0.title : nil) ?? "Untitled event",
                    start: $0.startDate, end: $0.endDate, isAllDay: $0.isAllDay,
                    location: $0.location?.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        lastRefresh = now
    }
}
