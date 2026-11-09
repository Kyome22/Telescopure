import SwiftUI

@available(iOS 27.1, *)
private struct FoldableLayoutModifier: ViewModifier {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
    @State private var hinge: DeviceHinge?

    private var browserToolbarLayout: BrowserToolbarLayout {
        if toolbarVerticalEdge != nil {
            .verticalBar
        } else if hinge != nil {
            .floatingBar
        } else {
            .footer
        }
    }

    func body(content: Content) -> some View {
        content
            .environment(\.browserToolbarLayout, browserToolbarLayout)
            .statusBarHidden(hinge.map { $0.status != .closed } ?? false)
            .onHingeChange { _, newContext in
                hinge = newContext.hinge
            }
    }
}

extension View {
    @ViewBuilder
    func resolvesFoldableLayout() -> some View {
        if #available(iOS 27.1, *) {
            modifier(FoldableLayoutModifier())
        } else {
            self
        }
    }
}
