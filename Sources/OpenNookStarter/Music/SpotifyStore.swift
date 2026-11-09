import AppKit
import Combine

/// Spotify's installed scripting dictionary is the API contract for this bridge.
private actor SpotifyBridge {
    func execute(_ body: String) throws -> [String] {
        let source = "with timeout of 3 seconds\n tell application id \"com.spotify.client\"\n\(body)\n end tell\nend timeout"
        guard let script = NSAppleScript(source: source) else { throw BridgeError.failed }
        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)
        if error != nil { throw BridgeError.failed }
        return (1...max(1, result.numberOfItems)).map { result.atIndex($0)?.stringValue ?? result.stringValue ?? "" }
    }
    enum BridgeError: Error { case failed }
}

@MainActor
final class SpotifyStore: ObservableObject {
    static let shared = SpotifyStore()
    @Published private(set) var connected = false
    @Published private(set) var playing = false
    @Published private(set) var title = "Nothing playing"
    @Published private(set) var artist = ""
    @Published private(set) var album = ""
    @Published private(set) var duration: Double = 1
    @Published private(set) var position: Double = 0
    @Published private(set) var artworkURL: URL? {
        didSet { if artworkURL != oldValue { loadArtwork() } }
    }
    @Published private(set) var artwork: NSImage?
    @Published private(set) var artworkTint = NSColor(white: 0.85, alpha: 1)
    private var artworkTask: Task<Void, Never>?
    @Published private(set) var shuffled = false
    @Published private(set) var repeated = false
    @Published private(set) var message: String?
    @Published private(set) var busy = false
    var liveModeChanged: ((Bool) -> Void)?
    private let bridge = SpotifyBridge()
    private var polling: Task<Void, Never>?
    private var enabled = false

    func connect() {
        guard Bundle.main.object(forInfoDictionaryKey: "NSAppleEventsUsageDescription") != nil else {
            message = "Launch the bundled app to connect Spotify."
            return
        }
        enabled = true
        UserDefaults.standard.set(true, forKey: "personalnotch.spotify.enabled")
        startPolling()
    }

    func resumeConnection() {
        if UserDefaults.standard.bool(forKey: "personalnotch.spotify.enabled") { connect() }
    }

    private func startPolling() {
        guard polling == nil else { return }
        polling = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refresh()
                do { try await Task.sleep(for: .seconds(2)) } catch { break }
            }
        }
    }

    func refresh() async {
        guard enabled, !busy else { return }
        guard !NSRunningApplication.runningApplications(withBundleIdentifier: "com.spotify.client").isEmpty else {
            connected = false
            setPlaying(false)
            message = "Open Spotify on this Mac, sign in, and play a song."
            return
        }
        busy = true
        defer { busy = false }
        do {
            let fields = try await bridge.execute("""
            if player state is stopped then return {"stopped"}
            set t to current track
            return {(player state as text), (name of t as text), (artist of t as text), (album of t as text), (duration of t as text), (player position as text), (artwork url of t as text), (shuffling as text), (repeating as text)}
            """)
            connected = true
            message = nil
            guard fields.count == 9 else { title = "Nothing playing"; artist = ""; album = ""; artworkURL = nil; position = 0; setPlaying(false); return }
            title = fields[1]; artist = fields[2]; album = fields[3]
            duration = max(1, (Double(fields[4]) ?? 1000) / 1000)
            position = min(duration, max(0, Double(fields[5].replacingOccurrences(of: ",", with: ".")) ?? 0))
            artworkURL = URL(string: fields[6]).flatMap { $0.scheme == "https" ? $0 : nil }
            shuffled = fields[7] == "true"; repeated = fields[8] == "true"
            setPlaying(fields[0] == "playing")
        } catch {
            connected = false
            setPlaying(false)
            message = "Allow Spotify in System Settings → Privacy & Security → Automation, then reconnect."
            polling?.cancel(); polling = nil
        }
    }

    private func loadArtwork() {
        artworkTask?.cancel()
        artwork = nil
        artworkTint = NSColor(white: 0.85, alpha: 1)
        guard let url = artworkURL else { return }
        artworkTask = Task { [weak self] in
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled,
                      let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
                      let image = NSImage(data: data), let self, self.artworkURL == url else { return }
                self.artwork = image
                self.artworkTint = ArtworkPalette.tint(from: image)
            } catch {
                // Missing artwork uses the neutral placeholder; playback remains usable.
            }
        }
    }

    private func setPlaying(_ value: Bool) {
        if playing != value { playing = value; liveModeChanged?(value) }
    }

    func command(_ command: String) {
        guard connected else { return }
        Task {
            while busy {
                do { try await Task.sleep(for: .milliseconds(50)) } catch { return }
            }
            guard connected else { return }
            busy = true
            do { _ = try await bridge.execute(command) }
            catch { message = "Spotify could not complete that control. Check Automation access." }
            busy = false
            await refresh()
        }
    }

    func seek(_ value: Double) {
        command("set player position to \(Int(max(0, min(duration, value))))")
    }
}
