import DataSource
import Model
import SwiftUI

struct Header: View {
    @Environment(\.appDependencies) private var appDependencies
    @Environment(\.isLoading) private var isLoading
    @Environment(\.estimatedProgress) private var estimatedProgress
    @State private var cornerInsets = CornerInsetsBeyondSafeArea()
    private let standardMargin: CGFloat = 16
    var store: Browser

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    Task {
                        await store.send(.settingsButtonTapped(appDependencies))
                    }
                } label: {
                    Label {
                        Text("openSettings", bundle: .module)
                    } icon: {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                    }
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
                .tint(Color(.systemGray))
                SearchBar(store: store)
            }
            .padding(.vertical, 8)
            .padding(.leading, standardMargin + cornerInsets.leading)
            .padding(.trailing, standardMargin + cornerInsets.trailing)
            .background(Color(.header))
            ProgressView(value: estimatedProgress)
                .opacity(isLoading ? 1.0 : 0.0)
        }
        .onGeometryChange(for: CornerInsetsBeyondSafeArea.self) { geometry in
            CornerInsetsBeyondSafeArea(geometry)
        } action: { newValue in
            cornerInsets = newValue
        }
    }
}

private struct CornerInsetsBeyondSafeArea: Equatable {
    var leading: CGFloat = 0
    var trailing: CGFloat = 0

    init() {}

    init(_ geometry: GeometryProxy) {
        guard #available(iOS 26, *) else { return }
        let containerCornerInsets = geometry.containerCornerInsets
        let safeAreaInsets = geometry.safeAreaInsets
        let headerTop = geometry.frame(in: .global).minY
        leading = Self.overlap(of: containerCornerInsets.topLeading, beyond: safeAreaInsets.leading, headerTop: headerTop)
        trailing = Self.overlap(of: containerCornerInsets.topTrailing, beyond: safeAreaInsets.trailing, headerTop: headerTop)
    }

    private static func overlap(of cornerInset: CGSize, beyond safeAreaInset: CGFloat, headerTop: CGFloat) -> CGFloat {
        guard cornerInset.height > headerTop else { return 0 }
        return max(0, cornerInset.width - safeAreaInset)
    }
}

#Preview {
    Header(store: .init(.testDependencies()))
}
