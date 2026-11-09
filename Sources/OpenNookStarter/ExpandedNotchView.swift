import SwiftUI

private enum ExpandedLayout {
    static let designHeight: CGFloat = 196
    static let scale: CGFloat = 0.9
}

/// One shared viewport keeps every tab, including empty/permission states, identical.
struct ExpandedNotchView: View {
    @ObservedObject var store: WidgetStore
    var body: some View {
        GeometryReader { geometry in
            pageCanvas
                .frame(width: geometry.size.width / ExpandedLayout.scale,
                       height: ExpandedLayout.designHeight, alignment: .top)
                .scaleEffect(ExpandedLayout.scale, anchor: .topLeading)
        }
        .frame(height: ExpandedLayout.designHeight * ExpandedLayout.scale)
        .foregroundStyle(.white)
        .environment(\.colorScheme, .dark)
    }

    private var pageCanvas: some View {
        VStack(spacing: 10) {
            HStack {
                Text(title).font(.system(size: 11, weight: .medium)).foregroundStyle(.secondary)
                    .lineLimit(1).frame(maxWidth: 150, alignment: .leading)
                Spacer()
                HStack(spacing: 5) {
                    tab(.home, "Home", "house")
                    tab(.calendar, "Calendar", "calendar")
                    tab(.music, "Music", "music.note")
                    tab(.focus, "Focus timer", "timer")
                }
            }.frame(height: 22)
            Group {
                switch store.selectedScreen {
                case .home:
                    VStack(spacing: 8) {
                        NotchBrandMark(size: 24, color: .white.opacity(0.7))
                        Text("Your space").font(.system(size: 15, weight: .medium))
                        Text("Home widgets will come next.").font(.system(size: 11)).foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                case .calendar: CalendarWidget(calendar: CalendarStore.shared)
                case .music: MusicWidget(player: SpotifyStore.shared)
                case .focus: QuickToolsWidget(store: store)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 164)
            .clipped()
        }
    }

    private func tab(_ screen: WidgetScreen, _ title: String, _ symbol: String) -> some View {
        Button { store.selectedScreen = screen } label: {
            Group {
                if screen == .music {
                    SpotifyMark().frame(width: 13, height: 13)
                } else {
                    Image(systemName: symbol).font(.system(size: 11, weight: .medium))
                }
            }
                .foregroundStyle(store.selectedScreen == screen ? .white : .gray)
                .frame(width: 22, height: 22)
                .background(store.selectedScreen == screen ? .white.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 6))
        }.buttonStyle(.plain).help(title).accessibilityLabel(title)
            .accessibilityAddTraits(store.selectedScreen == screen ? .isSelected : [])
    }
    private var title: String {
        switch store.selectedScreen { case .home: "Home"; case .calendar: "Today"; case .music: "Now Playing"; case .focus: "Focus" }
    }
}
