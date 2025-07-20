import Model
import SwiftUI
import WebUI

struct BrowserView: View {
    @Environment(\.appDependencies) private var appDependencies
    @StateObject var store: Browser
    @StateObject private var navigationDelegate: BrowserNavigationDelegate
    @StateObject private var uiDelegate: BrowserUIDelegate

    init(store: Browser) {
        _store = .init(wrappedValue: store)
        _navigationDelegate = .init(wrappedValue: .init(store: store.browserNavigation))
        _uiDelegate = .init(wrappedValue: .init(store: store.browserUI))
    }

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
                        .navigationDelegate(navigationDelegate)
                        .uiDelegate(uiDelegate)
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
                        ToolBar(
                            store: store,
                            canGoBack: proxy.canGoBack,
                            canGoForward: proxy.canGoForward
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
                .background(Color(.secondarySystemBackground))
                .task {
                    await store.send(.task(.init(
                        getLocalizedString: { $0.string },
                        getResourceURL: { Bundle.module.url(forResource: $0, withExtension: $1) },
                    ), proxy))
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
        .ignoresSafeArea(edges: store.isPresentedToolBar ? [] : .all)
        .sheet(item: $store.settings) { store in
            SettingsView(store: store)
        }
        .sheet(item: $store.bookmarkManagement) { store in
            BookmarkManagementView(store: store)
        }
        .alert(Text(verbatim: ""), isPresented: $store.isPresentedWebDialog, presenting: store.webDialog) { webDialog in
            if case let .prompt(_, defaultText, _) = webDialog {
                TextField(defaultText, text: $store.promptInput)
            }
            Button {
                Task {
                    await store.send(.dialogOKButtonTapped)
                }
            } label: {
                Text("ok", bundle: .module)
            }
            if webDialog.needsCancel {
                Button(role: .cancel) {
                    Task {
                        await store.send(.dialogCancelButtonTapped)
                    }
                } label: {
                    Text("cancel", bundle: .module)
                }
            }
        } message: { webDialog in
            Text(webDialog.message)
        }
        .onOpenURL { url in
            Task {
                await store.send(.onOpenURL(url))
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    BrowserView(store: .init(.testDependencies()))
}
