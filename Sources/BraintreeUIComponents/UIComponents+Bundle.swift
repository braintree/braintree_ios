import Foundation

extension Bundle {

    static var uiComponents: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }
}

private final class BundleToken {}
