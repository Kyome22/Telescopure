import SwiftUI

private struct LargeIconLabelStyle: LabelStyle {
    @ScaledMetric var imageSize = 40

    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            configuration.icon
                .imageScale(.large)
                .frame(width: imageSize, height: imageSize)
        }
        .labelStyle(.iconOnly)
    }
}

struct ToolbarButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: configuration.trigger) {
            configuration.label.labelStyle(LargeIconLabelStyle())
        }
        .buttonStyle(.borderless)
    }
}

extension PrimitiveButtonStyle where Self == ToolbarButtonStyle {
    static var toolbar: ToolbarButtonStyle { Self() }
}
