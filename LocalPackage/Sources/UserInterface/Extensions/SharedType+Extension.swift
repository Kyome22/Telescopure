import DataSource
import SwiftUI

extension SharedType {
    var labelKey: LocalizedStringKey {
        switch self {
        case .undefined: "undefined"
        case .link: "openIn"
        case .plainText: "searchIn"
        }
    }
}
