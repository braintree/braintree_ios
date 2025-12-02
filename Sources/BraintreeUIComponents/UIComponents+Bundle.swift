import Foundation

extension Bundle {

    static var uiComponents: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #elseif COCOAPODS
        let frameworkBundle = Bundle(for: BundleToken.self)
        if let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("BraintreeUIComponents.bundle") {
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            }
        }
        return frameworkBundle
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }
}

private final class BundleToken {}
