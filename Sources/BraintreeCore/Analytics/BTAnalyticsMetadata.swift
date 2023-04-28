import UIKit

// TODO: - Update to mirror params sent in Android and JS SDKs. Currently these analytics details params are being sent in all POST bodies.
// JIRA - DTBTSDK-2683
struct BTAnalyticsMetadata {

    // MARK: Metadata Properties

    static let platform: String = "iOS"
    static let platformVersion: String = UIDevice.current.systemVersion
    static let sdkVersion: String = BTCoreConstants.braintreeSDKVersion
    static let merchantAppID: String = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
    static let merchantAppVersion: String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
    static let merchantAppName: String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    static let deviceManufacturer: String = "Apple"
    static let iOSDeviceName: String = UIDevice.current.name
    static let iOSSystemName: String = UIDevice.current.systemName

    // MARK: Metadata Computed Properties

    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    static var iOSPackageManager: String {
        #if COCOAPODS
            return "CocoaPods"
        #elseif SWIFT_PACKAGE
            return "Swift Package Manager"
        #else
            return "Carthage or Other"
        #endif
    }

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    static var isVenmoInstalled: Bool {
        guard let venmoURL = URL(string: "com.venmo.touch.v2://x-callback-url/vzero/auth") else { return false }
        return UIApplication.shared.canOpenURL(venmoURL)
    }

    static var dropInVersion: String {
        var dropInVersion: String = ""
        let localizationBundlePath = Bundle.main.path(forResource: "Braintree-UIKit-Localization", ofType: "bundle")
        if localizationBundlePath != nil, let localizationBundlePath {
            let localizationBundle = Bundle(path: localizationBundlePath)
            // 99.99.99 is the version specified when running the Demo app for this project.
            // We want to ignore it in this case and not return a version.
            if localizationBundle != nil && localizationBundle?.infoDictionary?["CFBundleShortVersionString"] as? String != "99.99.99" {
                dropInVersion = localizationBundle?.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            }
        }
        return dropInVersion
    }

    // MARK: - Construct Metadata

    static var metadata: [String: Any] {
        [
            "platform": platform,
            "platformVersion": platformVersion,
            "sdkVersion": sdkVersion,
            "merchantAppId": merchantAppID,
            "merchantAppName": merchantAppName,
            "merchantAppVersion": merchantAppVersion,
            "deviceManufacturer": deviceManufacturer,
            "deviceModel": deviceModel,
            "iosDeviceName": iOSDeviceName,
            "iosSystemName": iOSSystemName,
            "iosPackageManager": iOSPackageManager,
            "isSimulator": isSimulator,
            "venmoInstalled": isVenmoInstalled,
            "dropinVersion": dropInVersion
        ]
    }
}
