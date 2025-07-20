import DataSource
import SwiftUI

extension SharedType {
    var label: String {
        let localizationValue: String.LocalizationValue = switch self {
        case .undefined: "undefined"
        case .link: "openIn"
        case .plainText: "searchIn"
        }
        return String(localized: localizationValue, bundle: .module)
    }
}
