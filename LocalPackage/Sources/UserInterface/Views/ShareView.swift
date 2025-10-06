import DataSource
import Model
import SwiftUI

public struct ShareView: View {
    @StateObject private var store: Share

    public init(store: Share) {
        _store = .init(wrappedValue: store)
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            NavigationStack {
                VStack {
                    Label {
                        Text(store.sharedType.sharedText)
                            .lineLimit(7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } icon: {
                        Image(systemName: store.sharedType.symbolName)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
                    Spacer()
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .navigationTitle(Text("telescopure", bundle: .module))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .cancel) {
                            Task {
                                await store.send(.cancelButtonTapped)
                            }
                        } label: {
                            Text("cancel", bundle: .module)
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button(role: .confirm) {
                            Task {
                                await store.send(.confirmButtonTapped)
                            }
                        } label: {
                            Text(store.sharedType.confirmLabel)
                        }
                    }
                }
            }
            .task {
                await store.send(.task)
            }
        } else {
            VStack(spacing: 16) {
                Button {
                    Task {
                        await store.send(.cancelButtonTapped)
                    }
                } label: {
                    Text("cancel", bundle: .module)
                }
                Color(.systemGray3)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                Text(store.sharedType.sharedText)
                    .lineLimit(7)
                    .foregroundColor(Color.primary)
                Color(.systemGray3)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                Button {
                    Task {
                        await store.send(.confirmButtonTapped)
                    }
                } label: {
                    Text(store.sharedType.confirmLabel)
                }
            }
            .padding(16)
            .background(Color(.systemGray5), in: .rect(cornerRadius: 12))
            .compositingGroup()
            .shadow(radius: 8)
            .padding(40)
            .task {
                await store.send(.task)
            }
        }
    }
}

extension Share: ObservableObject {}

#Preview {
    ShareView(store: .init(
        nsExtensionContextClient: testDependency(of: NSExtensionContextClient.self) {
            $0.inputItems = { _ in
                let item = NSExtensionItem()
                item.attachments = [
                    NSItemProvider(
                        item: NSURL(string: "https://example.com/programming/swift/telescopure"),
                        typeIdentifier: "public.url"
                    ),
                    NSItemProvider(
                        item: NSString(string: "Hello Swift!"),
                        typeIdentifier: "public.plain-text"
                    ),
                ]
                return [item]
            }
        },
        extensionContext: { nil },
        openURL: { _ in }
    ))
}
