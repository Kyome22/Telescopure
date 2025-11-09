import DataSource

public extension PageScale {
    func scaleUpped() -> Self {
        if self == .scale300 {
            self
        } else {
            PageScale(rawValue: rawValue + 1)!
        }
    }

    func scaleDowned() -> Self {
        if self == .scale50 {
            self
        } else {
            PageScale(rawValue: rawValue - 1)!
        }
    }
}
