enum BrowserToolbarLayout {
    case footer
    case floatingBar
    case verticalBar

    var usesSystemToolbar: Bool {
        self != .footer
    }
}
