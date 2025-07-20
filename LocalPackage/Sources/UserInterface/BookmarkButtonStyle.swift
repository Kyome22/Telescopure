import SwiftUI

struct BookmarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
        }
        .contentShape(Rectangle())
        .opacity(configuration.isPressed ? 0.3 : 1.0)
    }
}

extension ButtonStyle where Self == BookmarkButtonStyle {
    static var bookmark: BookmarkButtonStyle { Self() }
}
