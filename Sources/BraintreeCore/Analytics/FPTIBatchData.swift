import UIKit

// swiftlint:disable nesting
/// The POST body for a batch upload of FPTI events
struct FPTIBatchData: Codable {
    
    let events: [EventsContainer] // Single-element "events" array required by FPTI formatting
    
    init(metadata: Metadata, events fptiEvents: [Event]?) {
        self.events = [
            EventsContainer(
                metadata: metadata,
                fptiEvents: fptiEvents ?? []
            )
        ]
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

        let appSwitchURL: URL?
        /// UTC millisecond timestamp when a networking task started establishing a TCP connection. See [Apple's docs](https://developer.apple.com/documentation/foundation/urlsessiontasktransactionmetrics#3162615).
        /// `nil` if a persistent connection is used.
        let connectionStartTime: Int?
        let correlationID: String?
        let endpoint: String?
        /// UTC millisecond timestamp when a networking task completed.
        let endTime: Int?
        let errorDescription: String?
        let eventName: String
        /// True if the `BTConfiguration` was retrieved from local cache after `tokenize()` call.
        /// False if the `BTConfiguration` was fetched remotely after `tokenize()` call.
        let isConfigFromCache: Bool?
        /// True if the PayPal or Venmo request is to be vaulted
        let isVaultRequest: Bool?
        /// The type of link the SDK will be handling, currently deeplink or universal
        let linkType: String?
        /// The experiment details associated with a shopper insights flow
        let merchantExperiment: String?
        /// The list of payment methods displayed, in the same order in which they are rendered on the page, associated with the `BTShopperInsights` flow.
        let paymentMethodsDisplayed: String?
        /// Used for linking events from the client to server side request
        /// This value will be PayPal Order ID, Payment Token, EC token, Billing Agreement, or Venmo Context ID depending on the flow
        let payPalContextID: String?

        /// UTC millisecond timestamp when a networking task started requesting a resource. See [Apple's docs](https://developer.apple.com/documentation/foundation/urlsessiontasktransactionmetrics#3162615).
        let requestStartTime: Int?
        /// UTC millisecond timestamp when a networking task initiated.
        let startTime: Int?
        let timestamp = String(Date().utcTimestampMilliseconds)
        let tenantName: String = "Braintree"
        
        init(
            appSwitchURL: URL? = nil,
            connectionStartTime: Int? = nil,
            correlationID: String? = nil,
            endpoint: String? = nil,
            endTime: Int? = nil,
            errorDescription: String? = nil,
            eventName: String,
            isConfigFromCache: Bool? = nil,
            isVaultRequest: Bool? = nil,
            linkType: String? = nil,
            merchantExperiment: String? = nil,
            paymentMethodsDisplayed: String? = nil,
            payPalContextID: String? = nil,
            requestStartTime: Int? = nil,
            startTime: Int? = nil
        ) {
            self.appSwitchURL = appSwitchURL
            self.connectionStartTime = connectionStartTime
            self.correlationID = correlationID
            self.endpoint = endpoint
            self.endTime = endTime
            self.errorDescription = errorDescription
            self.eventName = eventName
            self.isConfigFromCache = isConfigFromCache
            self.isVaultRequest = isVaultRequest
            self.linkType = linkType
            self.merchantExperiment = merchantExperiment
            self.paymentMethodsDisplayed = paymentMethodsDisplayed
            self.payPalContextID = payPalContextID
            self.requestStartTime = requestStartTime
            self.startTime = startTime
        }

        enum CodingKeys: String, CodingKey {
            case appSwitchURL = "appSwitchUrl"
            case connectionStartTime = "connect_start_time"
            case correlationID = "correlation_id"
            case errorDescription = "error_desc"
            case eventName = "event_name"
            case isConfigFromCache = "config_cached"
            case isVaultRequest = "is_vault"
            case linkType = "link_type"
            case merchantExperiment = "experiment"
            case paymentMethodsDisplayed = "payment_methods_displayed"
            case payPalContextID = "paypal_context_id"
            case requestStartTime = "request_start_time"
            case timestamp = "t"
            case tenantName = "tenant_name"
            case startTime = "start_time"
            case endTime = "end_time"
            case endpoint = "endpoint"
        }
    }
    
    /// The FPTI tags/ metadata applicable to all events in the batch upload.
    struct Metadata: Codable {
          
        static var application: URLOpener = UIApplication.shared

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

        let payPalInstalled: Bool = application.isPayPalAppInstalled()

        let platform = "iOS"

        let sessionID: String

        let tokenizationKey: String?

        let venmoInstalled: Bool = application.isVenmoAppInstalled()

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
            case payPalInstalled = "paypal_installed"
            case integrationType = "api_integration_type"
            case isSimulator = "is_simulator"
            case merchantAppVersion = "mapv"
            case merchantID = "merchant_id"
            case platform = "platform"
            case sessionID = "session_id"
            case tokenizationKey = "tokenization_key"
            case venmoInstalled = "venmo_installed"
        }
    }
}
