import Model
import SwiftUI
import WebUI

struct BrowserView: View {
    @Environment(\.usesSystemToolbar) private var usesSystemToolbar
    @Environment(\.usesVerticalToolbar) private var usesVerticalToolbar
    @StateObject var store: Browser

    private var ignoredContainerSafeAreaEdges: Edge.Set {
        if !store.isPresentedToolbar {
            .all
        } else if usesVerticalToolbar {
            .bottom
        } else {
            []
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WebViewReader { proxy in
                NavigationStack {
                    VStack(spacing: 0) {
                        if store.isPresentedToolbar {
                            Header(store: store)
                                .transition(.move(edge: .top))
                                .environment(\.isLoading, proxy.isLoading)
                                .environment(\.estimatedProgress, proxy.estimatedProgress)
                        }
                        WebView(configuration: .forTelescopure)
                            .navigationDelegate(store.navigationDelegate)
                            .uiDelegate(store.uiDelegate)
                            .refreshable()
                            .allowsBackForwardNavigationGestures(true)
                            .allowsOpaqueDrawing(proxy.url != nil)
                            .allowsInspectable(true)
                            .pageScaleFactor(store.pageScale.value)
                            .overlay {
                                if proxy.url == nil {
                                    LogoView()
                                }
                            }
                        if store.isPresentedToolbar, !usesSystemToolbar {
                            Footer(store: store)
                                .transition(.move(edge: .bottom))
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .ignoresSafeArea(.container, edges: ignoredContainerSafeAreaEdges)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .toolbarVisibility(.hidden, for: .navigationBar)
                    .toolbar {
                        if usesSystemToolbar {
                            ToolbarItemGroup(placement: .bottomBar) {
                                if store.isPresentedToolbar {
                                    BrowserNavigationButtons(store: store)
                                    Spacer()
                                    BrowserActionButtons(store: store)
                                } else {
                                    Spacer()
                                    ShowToolbarButton(store: store)
                                }
                            }
                        }
                    }
                    .environment(\.canGoBack, proxy.canGoBack)
                    .environment(\.canGoForward, proxy.canGoForward)
                }
                .task {
                    await store.send(.task(
                        String(describing: Self.self),
                        .init(getResourceURL: { Bundle.module.url(forResource: $0, withExtension: $1) }),
                        proxy
                    ))
                }
                .onChange(of: proxy.url) { _, newValue in
                    Task {
                        await store.send(.onChangeURL(newValue))
                    }
                }
                .onChange(of: proxy.title) { _, newValue in
                    Task {
                        await store.send(.onChangeTitle(newValue))
                    }
                }
            }
            if !store.isPresentedToolbar, !usesSystemToolbar {
                FloatingShowToolbarButton(store: store)
                    .padding(20)
                    .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(.container, edges: store.isPresentedToolbar || usesSystemToolbar ? [] : .all)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(item: $store.settings) { store in
            SettingsView(store: store)
        }
        .sheet(item: $store.bookmarkManagement) { store in
            BookmarkManagementView(store: store)
        }
        .webDialog(
            isPresented: $store.isPresentedWebDialog,
            presenting: store.webDialog,
            promptInput: $store.promptInput,
            okButtonTapped: { await store.send(.dialogOKButtonTapped) },
            cancelButtonTapped: { await store.send(.dialogCancelButtonTapped) },
            onChangeIsPresented: { await store.send(.onChangeIsPresentedWebDialog($0)) }
        )
        .externalAppConfirmationDialog(
            isPresented: $store.isPresentedConfirmationDialog,
            presenting: store.customSchemeURL,
            okButtonTapped: { await store.send(.confirmButtonTapped($0)) }
        )
        .alert(
            Text("failedToOpenExternalApp", bundle: .module),
            isPresented: $store.isPresentedAlert,
            actions: {}
        )
        .onOpenURL { url in
            Task {
                await store.send(.onOpenURL(url))
            }
        }
        .animation(.easeIn(duration: 0.2), value: store.isPresentedToolbar)
    }
}

@available(iOS 27.1, *)
private struct FoldableLayoutResolver: ViewModifier {
    @Environment(\.toolbarVerticalEdge) private var toolbarVerticalEdge
    @State private var hinge: DeviceHinge?

    func body(content: Content) -> some View {
        content
            .environment(\.usesSystemToolbar, hinge != nil || toolbarVerticalEdge != nil)
            .environment(\.usesVerticalToolbar, toolbarVerticalEdge != nil)
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
            modifier(FoldableLayoutResolver())
        } else {
            self
        }
    }
}

extension Browser: ObservableObject {}
extension BrowserNavigation: ObservableObject {}
extension BrowserUI: ObservableObject {}

#Preview(traits: .landscapeRight) {
    BrowserView(store: .init(.testDependencies()))
}
