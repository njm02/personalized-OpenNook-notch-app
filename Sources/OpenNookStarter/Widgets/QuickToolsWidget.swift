// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Glendon Chin (OpenNook reference layouts)
// Local modifications: personal notch app integration and real-data behavior.
// Layout adapted from OpenNook ShowcaseNook TimerScene.swift (Apache-2.0).
import NookApp
import SwiftUI

struct QuickToolsWidget: View {
    @ObservedObject var store: WidgetStore
    @State private var durationInput = ""
    @State private var inputError: String?
    @FocusState private var editingDuration: Bool
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let seconds = Int(ceil(store.remaining(at: context.date)))
            let running = store.timerDeadline != nil && seconds > 0
            HStack(spacing: 25) {
                ZStack {
                    ForEach(0..<60) { tick in
                        Capsule().fill(Double(tick) / 60 <= 1 - Double(seconds) / store.timerDuration ? Color.orange : .white.opacity(0.12))
                            .frame(width: tick % 5 == 0 ? 2 : 1, height: tick % 5 == 0 ? 9 : 5)
                            .offset(y: -61).rotationEffect(.degrees(Double(tick) * 6))
                    }
                    Circle().trim(from: 0, to: max(0, min(1, 1 - Double(seconds) / store.timerDuration)))
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90)).frame(width: 100, height: 100)
                    Image(systemName: "flame.fill").font(.system(size: 24)).foregroundStyle(.orange)
                }.frame(width: 136, height: 136)
                VStack(alignment: .leading, spacing: 4) {
                    Label("Deep work", systemImage: "brain.head.profile").font(.system(size: 12, weight: .semibold)).foregroundStyle(.orange)
                    Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                        .font(.system(size: 45, weight: .medium, design: .rounded)).monospacedDigit()
                    if let inputError {
                        Text(inputError).font(.system(size: 10)).foregroundStyle(.red).lineLimit(1)
                    } else if running, let end = store.timerDeadline {
                        Text("Ends at \(end.formatted(date: .omitted, time: .shortened))").font(.system(size: 10)).foregroundStyle(.secondary)
                    } else if seconds == 0 { Text("Session complete").font(.system(size: 10)).foregroundStyle(.secondary) }
                    HStack(spacing: 7) {
                        Button { startOrPause() } label: {
                            Label(running ? "Pause" : "Start", systemImage: running ? "pause.fill" : "play.fill")
                                .font(.system(size: 11, weight: .semibold)).padding(.horizontal, 12).frame(height: 27)
                                .foregroundStyle(.black).background(.white, in: Capsule())
                        }.buttonStyle(.plain)
                        Button("+5 min") { store.addFiveMinutes() }.buttonStyle(WidgetButtonStyle())
                        Button { store.resetTimer() } label: { Image(systemName: "arrow.counterclockwise") }.buttonStyle(WidgetButtonStyle()).help("Reset timer")
                    }
                    HStack(spacing: 7) {
                        Text("Duration").font(.system(size: 10)).foregroundStyle(.secondary)
                        TextField("min or mm:ss", text: $durationInput)
                            .textFieldStyle(.roundedBorder).controlSize(.small)
                            .font(.system(size: 11)).monospacedDigit()
                            .frame(width: 85).focused($editingDuration)
                            .onSubmit { applyDuration() }
                            .accessibilityLabel("Focus duration in minutes or minutes and seconds")
                        Button("Set") { applyDuration() }
                            .buttonStyle(.plain).font(.system(size: 10, weight: .medium))
                            .padding(.horizontal, 10).frame(height: 23)
                            .background(.white.opacity(0.08), in: Capsule())
                    }
                    .disabled(running)
                    .help(running ? "Pause to change duration" : "Enter minutes (25) or minutes:seconds (25:30), then press Return or Set")
                    .padding(.top, 3)
                }
                Spacer(minLength: 0)
            }
        }
        .onAppear { durationInput = FocusDuration.formatted(store.timerDuration) }
        .onChange(of: store.timerIsRunning) { _, running in if running { editingDuration = false } }
        .onChange(of: store.timerDuration) { _, value in durationInput = FocusDuration.formatted(value) }
        .nookKeepsExpanded(while: Binding(get: { editingDuration }, set: { editingDuration = $0 }))
    }

    private func startOrPause() {
        if !store.timerIsRunning && durationInput != FocusDuration.formatted(store.timerDuration) {
            guard applyDuration() else { return }
        }
        editingDuration = false
        inputError = nil
        store.toggleTimer()
    }

    @discardableResult
    private func applyDuration() -> Bool {
        guard store.setTimerDuration(durationInput) else {
            inputError = "Use minutes or mm:ss (up to 24 hours)."
            return false
        }
        durationInput = FocusDuration.formatted(store.timerDuration)
        inputError = nil
        editingDuration = false
        return true
    }
}
