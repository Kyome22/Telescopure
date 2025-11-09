import DataSource
import SwiftUI

struct PageZoomControlPanel: View {
    @ScaledMetric private var imageSize = 40
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
                    .imageScale(.large)
                    .frame(width: imageSize, height: imageSize)
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("zoomOutButton")
            Divider()
            Button {
                Task {
                    await zoomButtonTapped(.reset)
                }
            } label: {
                Text(pageScale.value, format: .percent)
                    .monospaced()
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("zoomInButton")
            .disabled(pageScale == .scale100)
            Divider()
            Button {
                Task {
                    await zoomButtonTapped(.zoomIn)
                }
            } label: {
                Image(systemName: "plus.magnifyingglass")
                    .imageScale(.large)
                    .frame(width: imageSize, height: imageSize)
            }
        }
        .padding()
    }
}

#Preview {
    PageZoomControlPanel(pageScale: .scale100, zoomButtonTapped: { _ in })
}
