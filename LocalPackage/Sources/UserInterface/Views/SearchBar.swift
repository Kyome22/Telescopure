import DataSource
import Model
import SwiftUI

struct SearchBar: View {
    @ScaledMetric private var height: CGFloat = 36
    @FocusState private var focusedField: FocusedField?
    @Bindable var store: Browser

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color(.systemGray))
                TextField(
                    String(localized: "search…", bundle: .module),
                    text: $store.inputText,
                    selection: $store.textSelection
                )
                .keyboardType(.webSearch)
                .accessibilityIdentifier("searchTextField")
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .textSelectionAffinity(.upstream)
                .focused($focusedField, equals: .search)
                .foregroundStyle(Color(.systemGray))
                .onSubmit {
                    Task {
                        await store.send(.onSubmit(store.inputText))
                    }
                }
                Button {
                    Task {
                        await store.send(.clearSearchButtonTapped)
                    }
                } label: {
                    Label {
                        Text("clear", bundle: .module)
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(store.inputText.isEmpty ? Color(.systemGray3) : Color(.systemGray))
                    }
                    .labelStyle(.iconOnly)
                }
                .accessibilityIdentifier("clearButton")
                .disabled(store.inputText.isEmpty)
            }
            .padding(.horizontal, 8)
            .frame(height: height)
            .background(Color(.systemGray5), in: .rect(cornerRadius: 10))

            if store.isInputingSearchBar {
                Button {
                    focusedField = nil
                    Task {
                        await store.send(.cancelSearchButtonTapped)
                    }
                } label: {
                    Text("cancel", bundle: .module)
                }
                .buttonStyle(.borderless)
                .transition(.asymmetric(insertion: .push(from: .trailing), removal: .slide))
            }
        }
        .animation(.easeInOut, value: store.isInputingSearchBar)
        .onChange(of: focusedField) { _, newValue in
            Task {
                await store.send(.onChangeFocusedField(newValue))
            }
        }
    }
}

#Preview {
    SearchBar(store: .init(.testDependencies()))
}
