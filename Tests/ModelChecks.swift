import Foundation
@main struct Checks {
    @MainActor static func main() async {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        func date(_ year: Int, _ month: Int, _ day: Int) -> Date { cal.date(from: DateComponents(year: year, month: month, day: day))! }
        for (year, month, count) in [(2024, 2, 29), (2026, 2, 28), (2026, 3, 31), (2026, 11, 30)] {
            let cells = MonthGrid.days(for: date(year, month, 15), calendar: cal)
            assert(cells.count == 42)
            assert(cells.compactMap { $0 }.count == count)
            assert(cal.component(.day, from: cells.compactMap { $0 }.first!) == 1)
        }
        assert(MonthGrid.days(for: date(2026, 11, 1), calendar: cal)[6] == date(2026, 11, 1))
        let store = WidgetStore()
        let start = Date(timeIntervalSince1970: 1000)
        assert(store.remaining(at: start) == 1500)
        store.toggleTimer(at: start)
        assert(store.remaining(at: start.addingTimeInterval(100)) == 1400)
        store.addFiveMinutes(at: start.addingTimeInterval(100))
        assert(store.remaining(at: start.addingTimeInterval(100)) == 1700)
        store.toggleTimer(at: start.addingTimeInterval(200))
        assert(store.remaining(at: start.addingTimeInterval(400)) == 1600)
        store.addFiveMinutes(at: start.addingTimeInterval(400))
        assert(store.remaining(at: start.addingTimeInterval(900)) == 1900)
        store.resetTimer(minutes: 50)
        assert(store.timerDeadline == nil && store.timerDuration == 3000 && store.pausedSeconds == 3000)
        store.toggleTimer(at: start)
        assert(store.remaining(at: start.addingTimeInterval(4000)) == 0)
        store.resetTimer(minutes: 15)
        assert(store.pausedSeconds == 900)
        for bar in 0..<4 {
            for step in 0..<100 {
                let value = PlaybackMotion.level(at: Double(step) * 0.13, bar: bar)
                assert(value >= 0.1 && value <= 1)
            }
            let boundary = (0.38 + Double(bar) * 0.07) / 1.2 * 4
            let before = PlaybackMotion.level(at: boundary - 0.000001, bar: bar)
            let after = PlaybackMotion.level(at: boundary + 0.000001, bar: bar)
            assert(abs(before - after) < 0.0001)
        }
        assert(abs(PlaybackMotion.level(at: 1, bar: 0) - PlaybackMotion.level(at: 4, bar: 0)) > 0.000001)
        let live = WidgetStore()
        live.toggleTimer()
        assert(live.timerIsRunning)
        live.toggleTimer()
        assert(!live.timerIsRunning)
        live.resetTimer(minutes: 15)
        live.toggleTimer(at: Date.now.addingTimeInterval(-899.85))
        assert(live.timerIsRunning)
        try! await Task.sleep(for: .milliseconds(350))
        assert(!live.timerIsRunning && live.timerDeadline == nil && live.remaining(at: .now) == 0)
        for (input, expected) in [("25", 1500.0), ("12:30", 750.0), ("0:01", 1.0), ("1440", 86400.0), (" 5 ", 300.0)] {
            assert(FocusDuration.seconds(from: input) == expected)
        }
        for input in ["", "0", "0:00", "-5", "2:60", "1:", ":30", "1:2:3", "2.5", "1440:01", "999999999999999999999"] {
            assert(FocusDuration.seconds(from: input) == nil)
        }
        live.toggleTimer()
        assert(live.setTimerDuration("12:30"))
        assert(!live.timerIsRunning && live.timerDeadline == nil && live.pausedSeconds == 750 && live.timerDuration == 750)
        assert(!live.setTimerDuration("bad") && live.pausedSeconds == 750)
        for screen in [WidgetScreen.home, .calendar, .music, .focus] {
            for music in [false, true] {
                for timer in [false, true] {
                    let expected: CompactLiveMode = screen == .music && music ? .music : (screen == .focus && timer ? .focus : .idle)
                    assert(CompactLiveMode.resolve(screen: screen, musicPlaying: music, timerRunning: timer) == expected)
                }
            }
        }
        var selectionNotifications = 0
        store.liveModeChanged = { _ in selectionNotifications += 1 }
        store.selectedScreen = .music
        assert(selectionNotifications == 1 && store.compactMode(musicPlaying: true) == .music)
        print("PASS: leap months, month alignment, fixed 42 cells, countdown, pause, +5 minutes running/paused, completion, presets, smooth randomized levels, live pause/background completion and custom duration validation and selected-screen live mode")
    }
}
