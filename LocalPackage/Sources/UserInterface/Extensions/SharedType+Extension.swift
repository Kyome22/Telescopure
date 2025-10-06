import DataSource
import SwiftUI

extension SharedType {
    var confirmLabel: String {
        if #available(iOS 26.0, *) {
            let localizationValue: String.LocalizationValue = switch self {
            case .undefined: "done"
            case .link: "open"
            case .plainText: "search"
            }
            return String(localized: localizationValue, bundle: .module)
        } else {
            let localizationValue: String.LocalizationValue = switch self {
            case .undefined: "done"
            case .link: "openIn"
            case .plainText: "searchIn"
            }
            return String(localized: localizationValue, bundle: .module)
        }
    }
}
