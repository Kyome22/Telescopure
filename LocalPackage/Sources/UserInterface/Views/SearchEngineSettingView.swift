import DataSource
import Model
import SwiftUI

struct SearchEngineSettingView: View {
    @State var store: SearchEngineSetting

    var body: some View {
        Form {
            Picker(selection: $store.selection) {
                ForEach(SearchEngine.allCases, id: \.self) { searchEngine in
                    Text(searchEngine.label)
                        .tag(searchEngine)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .navigationTitle(Text("searchEngine", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
        .onChange(of: store.selection) { _, newValue in
            Task {
                await store.send(.onChangeSearchEngine(newValue))
            }
        }
    }
}
