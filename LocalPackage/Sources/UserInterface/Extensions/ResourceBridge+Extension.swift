import Model
import SwiftUI

extension Browser.Action.ResourceBridge {
    var string: String {
        let localizationValue: String.LocalizationValue = switch self {
        case let .openExternalApp(urlString):
            "openExternalApp\(urlString)"
        case .failedToOpenExternalApp:
            "failedToOpenExternalApp"
        }
        return String(localized: localizationValue, bundle: .module)
    }
}
