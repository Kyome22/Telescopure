import Model
import SwiftUI

struct Footer: View {
    var store: Browser

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(Color(.border))
            HStack {
                BrowserNavigationButtons(store: store)
                Spacer()
                BrowserActionButtons(store: store)
            }
            .buttonStyle(.toolbar)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.footer))
        }
    }
}

#Preview {
    Footer(store: .init(.testDependencies()))
}
