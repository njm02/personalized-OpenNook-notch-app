// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Glendon Chin (OpenNook reference layouts)
// Local modifications: personal notch app integration and real-data behavior.
// Layout adapted from OpenNook ShowcaseNook AgendaScene.swift (Apache-2.0).
import EventKit
import SwiftUI

struct CalendarWidget: View {
    @ObservedObject var calendar: CalendarStore
    private let accent = Color(red: 1, green: 0.66, blue: 0.36)

    var body: some View {
        Group {
            if calendar.authorization == .fullAccess {
                HStack(alignment: .top, spacing: 16) {
                    monthView.frame(width: 180)
                    Divider().overlay(.white.opacity(0.08))
                    agenda.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Your classes, at a glance").font(.system(size: 17, weight: .semibold))
                        Text(calendar.authorization == .denied || calendar.authorization == .restricted
                             ? "Enable Calendars access in System Settings → Privacy & Security, then refresh."
                             : "Choose a calendar from this Mac. macOS requests full calendar access; this app reads events only.")
                            .font(.system(size: 11)).foregroundStyle(.secondary)
                        if calendar.requestingAccess { ProgressView().controlSize(.small) }
                        else if calendar.authorization == .denied || calendar.authorization == .restricted {
                            Button("Check access again") { calendar.refresh() }.buttonStyle(WidgetButtonStyle())
                        } else if calendar.hasUsageDescription {
                            Button("Connect Calendar") { Task { await calendar.connect() } }.buttonStyle(WidgetButtonStyle())
                        } else { Text("Launch the bundled app to connect.").font(.system(size: 11)) }
                        if let error = calendar.errorMessage { Text(error).font(.system(size: 11)).foregroundStyle(.secondary) }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .task {
            calendar.refresh()
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(60)) } catch { break }
                calendar.refresh()
            }
        }
    }

    private var monthView: some View {
        VStack(spacing: 3) {
            HStack(spacing: 5) {
                Text(calendar.displayedMonth, format: .dateTime.month(.wide).year())
                    .font(.system(size: 12, weight: .semibold))
                Spacer(minLength: 1)
                monthButton("Previous month", "chevron.left", -1)
                monthButton("Next month", "chevron.right", 1)
            }.frame(height: 20)
            HStack(spacing: 0) {
                ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { _, day in
                    Text(day).font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
            }
            let days = MonthGrid.days(for: calendar.displayedMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(days.indices, id: \.self) { index in
                    if let day = days[index] {
                        Button { calendar.chooseDay(day) } label: {
                            VStack(spacing: 0) {
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Calendar.current.isDate(day, inSameDayAs: calendar.selectedDay) ? .black : .white)
                                    .frame(width: 18, height: 18)
                                    .background(Calendar.current.isDate(day, inSameDayAs: calendar.selectedDay) ? accent : .clear, in: Circle())
                                Circle().fill(calendar.events(on: day).isEmpty ? .clear : .gray).frame(width: 2, height: 2)
                            }.frame(height: 20)
                        }.buttonStyle(.plain).accessibilityLabel(day.formatted(date: .complete, time: .omitted))
                            .accessibilityAddTraits(Calendar.current.isDate(day, inSameDayAs: calendar.selectedDay) ? .isSelected : [])
                    } else { Color.clear.frame(height: 20) }
                }
            }
        }
    }

    private func monthButton(_ title: String, _ symbol: String, _ amount: Int) -> some View {
        Button { calendar.moveMonth(amount) } label: { Image(systemName: symbol).font(.system(size: 9, weight: .semibold)).frame(width: 16, height: 18) }
            .buttonStyle(.plain).help(title).accessibilityLabel(title)
    }

    private var agenda: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(calendar.selectedDay, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                    .font(.system(size: 12, weight: .semibold)).lineLimit(1)
                Spacer(minLength: 1)
                Button("Today") { calendar.showToday() }.buttonStyle(.plain).font(.system(size: 9)).foregroundStyle(accent)
                Button { calendar.refresh() } label: { Image(systemName: "arrow.clockwise").font(.system(size: 10)) }.buttonStyle(.plain).help("Refresh calendar")
            }
            Picker("Class calendar", selection: Binding(get: { calendar.selectedID }, set: { calendar.select($0) })) {
                Text("Choose calendar…").tag("")
                if calendar.selectionUnavailable { Text("Calendar unavailable").tag(calendar.selectedID) }
                ForEach(calendar.calendars) { Text($0.label).tag($0.id) }
            }.labelsHidden().controlSize(.mini)
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    if calendar.selectedID.isEmpty || calendar.selectionUnavailable {
                        Text("Choose your class calendar above.").font(.system(size: 11)).foregroundStyle(.secondary).padding(.top, 8)
                    } else if calendar.events(on: calendar.selectedDay).isEmpty {
                        Text("No events for this day.").font(.system(size: 11)).foregroundStyle(.secondary).padding(.top, 8)
                    }
                    ForEach(Array(calendar.events(on: calendar.selectedDay).enumerated()), id: \.element.id) { index, event in
                        let marker = eventColor(at: index)
                        let past = event.end < Date.now
                        let now = !event.isAllDay && event.start <= Date.now && event.end > Date.now
                        HStack(alignment: .top, spacing: 8) {
                            Capsule().fill(marker).frame(width: 3)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(event.title).font(.system(size: 12, weight: .semibold)).strikethrough(past).lineLimit(2)
                                HStack(spacing: 4) {
                                    if event.isAllDay { Text("All day") }
                                    else { Text(event.start, style: .time); Text("–"); Text(event.end, style: .time) }
                                    if now { Text("Now").foregroundStyle(marker) }
                                }.font(.system(size: 9)).foregroundStyle(.secondary)
                                if let location = event.location, !location.isEmpty {
                                    Label(location, systemImage: "mappin").font(.system(size: 9)).foregroundStyle(.secondary).lineLimit(1)
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(7).background(now ? marker.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 8))
                        .opacity(past ? 0.45 : 1)
                    }
                }
            }
        }
    }

    /// Distinct hues for each event's position in the selected day's agenda.
    /// No short palette cycle, so later events do not repeat the first colors.
    private func eventColor(at index: Int) -> Color {
        let hue = (0.72 + Double(index) * 0.618033988749895).truncatingRemainder(dividingBy: 1)
        return Color(hue: hue, saturation: 0.62, brightness: 0.95)
    }

}
