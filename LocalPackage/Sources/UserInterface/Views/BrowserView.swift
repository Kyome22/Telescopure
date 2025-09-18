import Model
import SwiftUI
import WebUI

struct BrowserView: View {
    @Environment(\.appDependencies) private var appDependencies
    @StateObject var store: Browser

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WebViewReader { proxy in
                VStack(spacing: 0) {
                    if store.isPresentedToolBar {
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
                            .padding(.horizontal, 16)
                            .background(Color(.header))
                            ProgressView(value: proxy.estimatedProgress)
                                .opacity(proxy.isLoading ? 1.0 : 0.0)
                        }
                        .transition(.move(edge: .top))
                    }
                    WebView(configuration: .forTelescopure)
                        .navigationDelegate(store.navigationDelegate)
                        .uiDelegate(store.uiDelegate)
                        .refreshable()
                        .allowsBackForwardNavigationGestures(true)
                        .allowsOpaqueDrawing(false)
                        .allowsInspectable(true)
                        .overlay {
                            if proxy.url == nil {
                                LogoView()
                            }
                        }
                    if store.isPresentedToolBar {
                        ToolBar(store: store)
                            .transition(.move(edge: .bottom))
                            .environment(\.canGoBack, proxy.canGoBack)
                            .environment(\.canGoForward, proxy.canGoForward)
                    }
                }
                .background(Color(.secondarySystemBackground))
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
                if !store.isPresentedToolBar {
                    ShowToolBarButton(store: store)
                        .padding(20)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .ignoresSafeArea(.container, edges: store.isPresentedToolBar ? [] : .all)
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
    }
}

extension Browser: ObservableObject {}
extension BrowserNavigation: ObservableObject {}
extension BrowserUI: ObservableObject {}

#Preview(traits: .landscapeRight) {
    BrowserView(store: .init(.testDependencies()))
}
