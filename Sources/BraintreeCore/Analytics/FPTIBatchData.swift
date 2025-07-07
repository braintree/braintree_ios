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

        let appSwitchURL: String?
        /// The order or ranking in which payment buttons appear.
        let buttonOrder: String?
        /// The type of button displayed or presented
        let buttonType: String?
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
        /// The value passed by the merchant for `enablePayPalAppSwitch`
        let didEnablePayPalAppSwitch: Bool?
        /// Determined if `create_payment_resource` or `setup_billing_agreement` returned
        /// an app switch URL in the response
        let didPayPalServerAttemptAppSwitch: Bool?
        /// The experiment details associated with a shopper insights flow
        let merchantExperiment: String?
        /// The type of page where the payment button is displayed or where an event occured.
        let pageType: String?
        /// Used for linking events from the client to server side request
        /// This value will be PayPal Order ID, Payment Token, EC token, Billing Agreement, or Venmo Context ID depending on the flow
        let payPalContextID: String?

        /// UTC millisecond timestamp when a networking task started requesting a resource. See [Apple's docs](https://developer.apple.com/documentation/foundation/urlsessiontasktransactionmetrics#3162615).
        let requestStartTime: Int?
        /// The Shopper Insights customer session ID created by a merchant's server SDK or graphQL integration.
        let shopperSessionID: String?
        /// UTC millisecond timestamp when a networking task initiated.
        let startTime: Int?
        let timestamp = String(Date().utcTimestampMilliseconds)
        let tenantName: String = "Braintree"
        
        init(
            appSwitchURL: URL? = nil,
            buttonOrder: String? = nil,
            buttonType: String? = nil,
            connectionStartTime: Int? = nil,
            correlationID: String? = nil,
            didEnablePayPalAppSwitch: Bool? = nil,
            didPayPalServerAttemptAppSwitch: Bool? = nil,
            endpoint: String? = nil,
            endTime: Int? = nil,
            errorDescription: String? = nil,
            eventName: String,
            isConfigFromCache: Bool? = nil,
            isVaultRequest: Bool? = nil,
            linkType: String? = nil,
            merchantExperiment: String? = nil,
            pageType: String? = nil,
            payPalContextID: String? = nil,
            requestStartTime: Int? = nil,
            shopperSessionID: String? = nil,
            startTime: Int? = nil
        ) {
            self.appSwitchURL = appSwitchURL?.absoluteString
            self.buttonOrder = buttonOrder
            self.buttonType = buttonType
            self.connectionStartTime = connectionStartTime
            self.correlationID = correlationID
            self.didEnablePayPalAppSwitch = didEnablePayPalAppSwitch
            self.didPayPalServerAttemptAppSwitch = didPayPalServerAttemptAppSwitch
            self.endpoint = endpoint
            self.endTime = endTime
            self.errorDescription = errorDescription
            self.eventName = eventName
            self.isConfigFromCache = isConfigFromCache
            self.isVaultRequest = isVaultRequest
            self.linkType = linkType
            self.merchantExperiment = merchantExperiment
            self.pageType = pageType
            self.payPalContextID = payPalContextID
            self.requestStartTime = requestStartTime
            self.shopperSessionID = shopperSessionID
            self.startTime = startTime
        }

        enum CodingKeys: String, CodingKey {
            case appSwitchURL = "url"
            case buttonOrder = "button_position"
            case buttonType = "button_type"
            case connectionStartTime = "connect_start_time"
            case correlationID = "correlation_id"
            case didEnablePayPalAppSwitch = "merchant_enabled_app_switch"
            case didPayPalServerAttemptAppSwitch = "attempted_app_switch"
            case errorDescription = "error_desc"
            case eventName = "event_name"
            case isConfigFromCache = "config_cached"
            case isVaultRequest = "is_vault"
            case linkType = "link_type"
            case merchantExperiment = "experiment"
            case pageType = "page_type"
            case payPalContextID = "paypal_context_id"
            case requestStartTime = "request_start_time"
            case timestamp = "t"
            case tenantName = "tenant_name"
            case shopperSessionID = "shopper_session_id"
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
        
        let applicationState: String

        /// Either a randomly generated session ID or the shopper session ID passed in by a merchant
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
            case applicationState = "application_state"
            case tokenizationKey = "tokenization_key"
            case venmoInstalled = "venmo_installed"
        }
    }
}
