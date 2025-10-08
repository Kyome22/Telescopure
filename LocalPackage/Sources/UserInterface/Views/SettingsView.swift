import DataSource
import Model
import SwiftUI

struct SettingsView: View {
    @Environment(\.appDependencies) private var appDependencies
    @State var store: Settings

    var body: some View {
        NavigationStack(path: $store.path) {
            List {
                Section {
                    Button {
                        Task {
                            await store.send(.defaultBrowserAppButtonTapped)
                        }
                    } label: {
                        LabeledContent {
                            Image(systemName: "chevron.right")
                        } label: {
                            Label {
                                Text("defaultBrowserApp", bundle: .module)
                                    .foregroundStyle(Color.primary)
                            } icon: {
                                Image(systemName: "app.badge.checkmark")
                            }
                        }
                    }
                    .buttonStyle(.borderless)
                    Button {
                        Task {
                            await store.send(.searchEngineSettingButtonTapped(appDependencies))
                        }
                    } label: {
                        LabeledContent {
                            HStack {
                                Text(store.searchEngine.label)
                                Image(systemName: "chevron.right")
                            }
                        } label: {
                            Label {
                                Text("searchEngine", bundle: .module)
                                    .foregroundStyle(Color.primary)
                            } icon: {
                                Image(systemName: "magnifyingglass")
                            }
                        }
                    }
                    .buttonStyle(.borderless)
                    LabeledContent {
                        Button(role: .destructive) {
                            Task {
                                await store.send(.crearCacheButtonTapped)
                            }
                        } label: {
                            Text("clear", bundle: .module)
                        }
                        .buttonStyle(.borderless)
                    } label: {
                        Label {
                            Text("cache", bundle: .module)
                        } icon: {
                            Image(systemName: "trash")
                        }
                    }
                } header: {
                    Text("settings", bundle: .module)
                }
                Section {
                    LabeledContent {
                        Text(store.version)
                    } label: {
                        Label {
                            Text("version", bundle: .module)
                        } icon: {
                            Image(systemName: "number")
                        }
                    }
                    LabeledContent {
                        Text(store.developer)
                    } label: {
                        Label {
                            Text("developer", bundle: .module)
                        } icon: {
                            Image(systemName: "hammer")
                        }
                    }
                    Button {
                        Task {
                            await store.send(.openRepositoryButtonTapped)
                        }
                    } label: {
                        LabeledContent {
                            Image(systemName: "link")
                                .foregroundStyle(Color.accentColor)
                        } label: {
                            Label {
                                Text("repository", bundle: .module)
                                    .foregroundStyle(Color.primary)
                            } icon: {
                                Image(systemName: "shippingbox")
                            }
                        }
                    }
                    .buttonStyle(.borderless)
                    Button {
                        Task {
                            await store.send(.licensesButtonTapped(appDependencies))
                        }
                    } label: {
                        LabeledContent {
                            Image(systemName: "chevron.right")
                        } label: {
                            Label {
                                Text("licenses", bundle: .module)
                                    .foregroundStyle(Color.primary)
                            } icon: {
                                Image(systemName: "building.columns")
                            }
                        }
                    }
                    .buttonStyle(.borderless)
                } header: {
                    Text("information", bundle: .module)
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Settings.Path.self) { path in
                switch path {
                case let .searchEngineSetting(store):
                    SearchEngineSettingView(store: store)

                case let .licenses(store):
                    LicensesView(store: store)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await store.send(.doneButtonTapped)
                        }
                    } label: {
                        Text("done", bundle: .module)
                    }
                    .accessibilityIdentifier("doneSettingsButton")
                }
            }
        }
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
    }
}

#Preview {
    SettingsView(store: .init(.testDependencies(), id: UUID(), action: { _ in }))
}
