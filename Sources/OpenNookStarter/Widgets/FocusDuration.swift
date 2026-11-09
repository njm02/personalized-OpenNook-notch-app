import Foundation

enum FocusDuration {
    /// Plain minutes or mm:ss, from one second through 24 hours.
    static func seconds(from input: String) -> TimeInterval? {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text.count <= 16 else { return nil }
        let parts = text.split(separator: ":", omittingEmptySubsequences: false)
        guard (1...2).contains(parts.count), parts.allSatisfy({ !$0.isEmpty && $0.utf8.allSatisfy { (48...57).contains($0) } }),
              let minutes = Int(parts[0]), minutes <= 1440 else { return nil }
        let remainder = parts.count == 2 ? Int(parts[1]) : 0
        guard let remainder, remainder < 60 else { return nil }
        let total = minutes * 60 + remainder
        guard total > 0, total <= 86400 else { return nil }
        return TimeInterval(total)
    }

    static func formatted(_ seconds: TimeInterval) -> String {
        let value = Int(seconds)
        return String(format: "%d:%02d", value / 60, value % 60)
    }
}
