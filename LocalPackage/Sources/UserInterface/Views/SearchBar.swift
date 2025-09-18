import DataSource
import Model
import SwiftUI

struct SearchBar: View {
    @ScaledMetric private var height: CGFloat = 36
    @FocusState.Binding var focusedField: FocusedField?
    @State var store: Browser

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color(.systemGray))
            TextField(text: $store.inputText) {
                Text("search", bundle: .module)
            }
            .keyboardType(.webSearch)
            .accessibilityIdentifier("searchTextField")
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
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
    }
}

#Preview {
    SearchBar(focusedField: FocusState<FocusedField?>().projectedValue, store: .init(.testDependencies()))
}
