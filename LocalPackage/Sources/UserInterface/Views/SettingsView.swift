import DataSource
import Model
import SwiftUI

struct SettingsView: View {
    @Environment(\.appDependencies) private var appDependencies
    @Bindable var store: Settings

    var body: some View {
        NavigationStack(path: $store.path) {
            List {
                Section {
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
                            Text("searchEngine", bundle: .module)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    .buttonStyle(.borderless)
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
            .navigationTitle(Text(verbatim: "Telescopure"))
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await store.send(.closeButtonTapped)
                        }
                    } label: {
                        Label {
                            Text("close", bundle: .module)
                        } icon: {
                            Image(systemName: "xmark")
                        }
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("closeBookmarksButton")
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
