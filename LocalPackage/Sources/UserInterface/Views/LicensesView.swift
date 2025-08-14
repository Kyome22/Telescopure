import LicenseList
import Model
import SwiftUI

struct LicensesView: View {
    var store: Licenses

    var body: some View {
        LicenseListView()
            .licenseViewStyle(.withRepositoryAnchorLink)
            .navigationTitle(Text("licenses", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await store.send(.task(String(describing: Self.self)))
            }
    }
}
