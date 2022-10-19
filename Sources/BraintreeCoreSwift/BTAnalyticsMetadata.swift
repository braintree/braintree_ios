import Foundation
import UIKit

// TODO: convert to internal (and maybe struct) when BTAnalyticsSession is converted to Swift
@objcMembers public class BTAnalyticsMetadata: NSObject {

    // MARK: Metadata Properties

    static let platform: String = "iOS"
    static let platformVersion: String = UIDevice.current.systemVersion
    static let sdkVersion: String = BTCoreConstants.braintreeSDKVersion
    static let merchantAppID: String = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
    static let merchantAppVersion: String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
    static let merchantAppName: String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    static let deviceManufacturer: String = "Apple"
    static let iOSIdentifierForVendor: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    static let iOSBaseSDK: String = "\(__IPHONE_OS_VERSION_MAX_ALLOWED)"
    static let iOSDeviceName: String = UIDevice.current.name
    static let iOSSystemName: String = UIDevice.current.systemName
    static let isVenmoInstalled: Bool = UIApplication.shared.canOpenURL(URL(string: "com.venmo.touch.v2://x-callback-url/vzero/auth")!)
    static let isAppExtension: Bool = Bundle.main.bundleURL.pathExtension == "appex"

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

    static var iOSDeploymentTarget: String {
        let rawVersionString: String? = Bundle.main.infoDictionary?["MinimumOSVersion"] as? String
        let rawVersionArray: [String] = rawVersionString?.components(separatedBy: ".") ?? []
        let firstIndexAsInt: Int = Int(rawVersionArray.first ?? "0") ?? 0
        var formattedVersionNumber: Int = firstIndexAsInt * 10000

        if rawVersionArray.count > 1 {
            let indexAsInt: Int = Int(rawVersionArray[1]) ?? 0
            formattedVersionNumber += indexAsInt * 100
        }

        return String(formattedVersionNumber)
    }

    static var deviceAppGeneratedPersistentUUID: String {
        let deviceAppGeneratedPersistentUuidKeychainKey: String = "deviceAppGeneratedPersistentUuid"
        var savedIdentifier: String = BTKeychain.stringForKey(deviceAppGeneratedPersistentUuidKeychainKey)

        if savedIdentifier.count == 0 {
            savedIdentifier = UUID().uuidString
            let setDidSucceed = BTKeychain.setString(savedIdentifier, forKey: deviceAppGeneratedPersistentUuidKeychainKey)

            if !setDidSucceed {
                return ""
            }
        }

        return savedIdentifier
    }

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    static var deviceScreenOrientation: String {
        if isAppExtension {
            return "AppExtension"
        }

        switch UIDevice.current.orientation {
        case .faceUp:
            return "FaceUp"
        case .faceDown:
            return "FaceDown"
        case .portrait:
            return "Portrait"
        case .portraitUpsideDown:
            return "PortraitUpsideDown"
        case .landscapeLeft:
            return "LandscapeLeft"
        case .landscapeRight:
            return "LandscapeRight"
        default:
            return "Unknown"
        }
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

    // TODO: make internal when BTAnalyticsSession is converted to Swift
    public static var metadata: [String: Any] {
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
            "iosBaseSDK": iOSBaseSDK,
            "iosDeploymentTarget": iOSDeploymentTarget,
            "iosIdentifierForVendor": iOSIdentifierForVendor,
            "iosPackageManager": iOSPackageManager,
            "deviceAppGeneratedPersistentUuid": deviceAppGeneratedPersistentUUID,
            "isSimulator": isSimulator,
            "deviceScreenOrientation": deviceScreenOrientation,
            "venmoInstalled": isVenmoInstalled,
            "dropinVersion": dropInVersion
        ]
    }
}
