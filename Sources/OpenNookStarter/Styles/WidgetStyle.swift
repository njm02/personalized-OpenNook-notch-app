import SwiftUI

struct WidgetCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct WidgetHeading: View {
    let title: String
    let symbol: String
    var badge: String? = nil
    var body: some View {
        HStack(spacing: 6) {
            Label(title, systemImage: symbol)
                .font(.system(size: 11, weight: .medium))
            Spacer(minLength: 0)
            if let badge { Text(badge).font(.system(size: 10)) }
        }
        .foregroundStyle(.white.opacity(0.6))
    }
}

struct WidgetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .padding(8)
            .foregroundStyle(.white)
            .background(.white.opacity(configuration.isPressed ? 0.18 : 0.07), in: RoundedRectangle(cornerRadius: 8))
            .contentShape(Rectangle())
    }
}

struct SymbolButton: View {
    let title: String
    let symbol: String
    let action: () -> Void
    @State private var hovered = false
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol).frame(width: 18, height: 18)
        }
        .buttonStyle(WidgetButtonStyle())
        .brightness(hovered ? 0.12 : 0)
        .onHover { hovered = $0 }
        .help(title)
        .accessibilityLabel(title)
    }
}
