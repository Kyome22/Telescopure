import DataSource
import SwiftUI

struct PageZoomControlPanel: View {
    var pageScale: PageScale
    var zoomButtonTapped: (PageZoomCommand) async -> Void

    var body: some View {
        HStack {
            Button {
                Task {
                    await zoomButtonTapped(.zoomOut)
                }
            } label: {
                Image(systemName: "minus.magnifyingglass")
            }
            .buttonStyle(.toolbar)
            .accessibilityIdentifier("zoomOutButton")
            Divider()
            Button {
                Task {
                    await zoomButtonTapped(.zoomReset)
                }
            } label: {
                Text(pageScale.value, format: .percent)
                    .monospaced()
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("zoomResetButton")
            .disabled(pageScale == .scale100)
            Divider()
            Button {
                Task {
                    await zoomButtonTapped(.zoomIn)
                }
            } label: {
                Image(systemName: "plus.magnifyingglass")
            }
            .buttonStyle(.toolbar)
            .accessibilityIdentifier("zoomInButton")
        }
        .padding()
    }
}

#Preview {
    PageZoomControlPanel(pageScale: .scale100, zoomButtonTapped: { _ in })
}
