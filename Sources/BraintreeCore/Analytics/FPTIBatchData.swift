import Foundation
import UIKit

/// The POST body for a batch upload of FPTI events
struct FPTIBatchData: Codable {
    
    let events: [EventsContainer] // Single-element "events" array required by FPTI formatting
    
    init(metadata: Metadata, events fptiEvents: [Event]?) {
        self.events = [EventsContainer(
            metadata: metadata,
            fptiEvents: fptiEvents ?? []
        )]
    }
    
    struct EventsContainer: Codable {
        
        let metadata: Metadata
        let fptiEvents: [Event]

        enum CodingKeys: String, CodingKey {
            case metadata = "batch_params"
            case fptiEvents = "event_params"
        }
    }
    
    /// Encapsulates a single event by it's name and timestamp.
    struct Event: Codable {
        
        let correlationID: String?
        let errorDescription: String?
        let eventName: String
        let timestamp: String
        let tenantName: String = "Braintree"

        enum CodingKeys: String, CodingKey {
            case correlationID = "correlation_id"
            case errorDescription = "error_desc"
            case eventName = "event_name"
            case timestamp = "t"
            case tenantName = "tenant_name"
        }
    }
    
    /// The FPTI tags/ metadata applicable to all events in the batch upload.
    struct Metadata: Codable {
            
        let appID: String = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "N/A"

        let appName: String = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "N/A"
        
        let authorizationFingerprint: String?
        
        let clientSDKVersion = BTCoreConstants.braintreeSDKVersion

        let clientOS: String = UIDevice.current.systemName + " " + UIDevice.current.systemVersion

        let component = "braintreeclientsdk"

        let deviceManufacturer = "Apple"

        let deviceModel: String = {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }()

        let eventSource = "mobile-native"

        let environment: String?
        
        let packageManager: String = {
            #if COCOAPODS
                "CocoaPods"
            #elseif SWIFT_PACKAGE
                "Swift Package Manager"
            #else
                "Carthage or Other"
            #endif
        }()
        
        let integrationType: String

        let isSimulator: Bool = {
            #if targetEnvironment(simulator)
                true
            #else
                false
            #endif
        }()

        let merchantAppVersion: String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? "N/A"

        let merchantID: String?
        
        let platform = "iOS"

        let sessionID: String

        let tokenizationKey: String?

        enum CodingKeys: String, CodingKey {
            case appID = "app_id"
            case appName = "app_name"
            case authorizationFingerprint = "auth_fingerprint"
            case clientSDKVersion = "c_sdk_ver"
            case clientOS = "client_os"
            case component = "comp"
            case deviceManufacturer = "device_manufacturer"
            case deviceModel = "mobile_device_model"
            case eventSource = "event_source"
            case environment = "merchant_sdk_env"
            case packageManager = "ios_package_manager"
            case integrationType = "api_integration_type"
            case isSimulator = "is_simulator"
            case merchantAppVersion = "mapv"
            case merchantID = "merchant_id"
            case platform = "platform"
            case sessionID = "session_id"
            case tokenizationKey = "tokenization_key"
        }
    }
}
