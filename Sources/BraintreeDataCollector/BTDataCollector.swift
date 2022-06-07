import Foundation
import CoreLocation
import PPRiskMagnes
import Security

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeKountDataCollector)
import BraintreeKountDataCollector
#endif

/// Braintree's advanced fraud protection solution.
@objcMembers public class BTDataCollector: NSObject {
    
    /// The Kount SDK device collector, exposed internally for testing
    var kount: KDataCollector?

    private var fraudMerchantID: String?
    private let apiClient: BTAPIClient
    private let defaultKountMerchantID: Int = 60000
    
    // TODO: overriding load() has been deprecated for a while. Right now we are using it to load PPDataCollector if needed in this class. Since these 2 classes will be combined, leaving this out for now.
    
    ///  Initializes a `BTDataCollector` instance with a `BTAPIClient`.
    /// - Parameter apiClient: An instance of `BTAPIClient`
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
        super.init()
        setUpKountWithDebugOn(false)
    }
    
    // MARK: Public methods
    
    /// Returns a client metadata ID.
    /// - Parameter pairingID: A pairing ID to associate with this clientMetadataID must be 10-32 chars long or null
    /// - Returns: A client metadata ID to send as a header
    /// - Note: This returns a raw client metadata ID, which is not the correct format for device data when creating a transaction. Instead, it is recommended to use `collectDeviceData`.
    public func clientMetadataID(_ pairingID: String?) -> String {
        generateClientMetadataID(pairingID, disableBeacon: false, configuration: nil, data: nil)
    }
    
    /// Collects device data based on your merchant configuration.
    ///
    ///  We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
    ///  calling it when the customer initiates checkout is also fine.
    ///  Use the return value on your server, e.g. with `Transaction.sale`.
    ///  - Parameter completion:  A completion block that returns a device data string that should be passed into server-side calls, such as `Transaction.sale`.
    public func collectDeviceData(_ completion: @escaping (String? , Error?) -> Void) {
        collectDeviceData(kountMerchantID: nil, completion)
    }
    
    /// This method should only be used by legacy merchants approved to use Kount Custom. Collects device data based on your merchant configuration.
    ///
    ///  We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
    ///  calling it when the customer initiates checkout is also fine.
    ///  Use the return value on your server, e.g. with `Transaction.sale`.
    ///  - Parameter completion:  A completion block that returns a device data string that should be passed into server-side calls, such as `Transaction.sale`.
    ///  - Parameter kountMerchantID: The fraudMerchantID you have established with your Braintree account manager. If you do not pass this value, a generic Braintree value will be used.
    public func collectDeviceData(kountMerchantID: String?, _ completion: @escaping (String? , Error?) -> Void) {
        fraudMerchantID = kountMerchantID
        kount?.merchantID = Int(kountMerchantID ?? String(defaultKountMerchantID)) ?? defaultKountMerchantID

        fetchConfiguration { configuration, error in
            guard let configuration = configuration else { return }

            if configuration.isKountEnabled {
                let braintreeEnvironment: BTDataCollectorEnvironment = self.environmentFromString(configuration.environment ?? "production")
                self.setDataCollectorEnvironment(as: self.collectorEnvironment(environment: braintreeEnvironment))

                guard let kountMerchantID = self.fraudMerchantID != nil ? self.fraudMerchantID : configuration.kountMerchantID else {
                    // TODO: return error
                    return
                }

                self.kount?.merchantID = Int(kountMerchantID) ?? self.defaultKountMerchantID
                
                let deviceSessionID: String = self.generateSessionID()
                let clientMetadataID: String = self.generateClientMetadataID(with: configuration)
                let dataDictionary: [String: String] = [
                    "device_session_id": deviceSessionID,
                    "fraud_merchant_id": kountMerchantID,
                    "correlation_id": clientMetadataID
                ]
                
                self.kount?.collect(forSession: deviceSessionID)

                guard let jsonData = try? JSONSerialization.data(withJSONObject: dataDictionary) else {
                    // TODO: return error
                    return
                }

                guard let deviceData = String(data: jsonData, encoding: .utf8) else {
                    // TODO: return error
                    return
                }

                completion(deviceData, nil)
            } else {
                // TODO: do we just need correlation ID if Kount is not enabled??
                let clientMetadataID: String = self.generateClientMetadataID(with: configuration)
                let dataDictionary: [String: String] = ["correlation_id": clientMetadataID]

                guard let jsonData = try? JSONSerialization.data(withJSONObject: dataDictionary) else {
                    // TODO: return error
                    return
                }

                guard let deviceData = String(data: jsonData, encoding: .utf8) else {
                    // TODO: return error
                    return
                }

                completion(deviceData, nil)
            }
        }
    }
    
    // MARK: Internal methods
    
    func fetchConfiguration(completion: @escaping (BTConfiguration?, Error?) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let configuration = configuration else {
                // TODO: return error
                completion(nil, error)
                return
            }
            
            completion(configuration, error)
        }
    }
    
    func setDataCollectorEnvironment(as environment: KEnvironment) {
        kount?.environment = environment
    }

    func setUpKountWithDebugOn(_ debugLogging: Bool) {
        kount = KDataCollector.shared()
        kount?.debug = debugLogging
        
        var locationStatus: CLAuthorizationStatus = .notDetermined
        let manager = CLLocationManager()

        if #available(iOS 14, *) {
            locationStatus = manager.authorizationStatus
        } else {
            locationStatus = CLLocationManager.authorizationStatus()
        }
        
        if locationStatus != .authorizedWhenInUse && locationStatus != .authorizedAlways || CLLocationManager.locationServicesEnabled() {
            kount?.locationCollectorConfig = .skip
        }
    }
    
    func generateSessionID() -> String {
        UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }
    
    func environmentFromString(_ environment: String) -> BTDataCollectorEnvironment {
        if environment == "production" {
            return .production
        } else if environment == "sandbox" {
            return .sandbox
        } else if environment == "qa" {
            return .qa
        } else {
            return .development
        }
    }
    
    func collectorEnvironment(environment: BTDataCollectorEnvironment) -> KEnvironment {
        switch environment {
        case .production:
            return .production
        default:
            return .test
        }
    }

    func getMagnesEnvironment(from configuration: BTConfiguration?) -> MagnesSDK.Environment {
        switch configuration?.environment {
        case "production":
            return .LIVE
        case "sandbox":
            return .SANDBOX
        default:
            return .LIVE
        }
    }
    
    func generateClientMetadataID(with configuration: BTConfiguration) -> String {
        generateClientMetadataID("", disableBeacon: false, configuration: configuration, data: nil)
    }
    
    func generateClientMetadataID(_ clientMetadataID: String?, disableBeacon: Bool, configuration: BTConfiguration?, data: [String : String]?) -> String {
        var config: BTConfiguration?
        
        if configuration != nil {
            config = configuration
        } else {
            fetchConfiguration { configuration, _ in
                config = configuration
            }
        }

        let mangnesEnvironment = getMagnesEnvironment(from: config)

        try? MagnesSDK.shared().setUp(setEnviroment: mangnesEnvironment,
                                      setOptionalAppGuid: deviceIdentifier(),
                                      disableRemoteConfiguration: false,
                                      disableBeacon: disableBeacon,
                                      magnesSource: .BRAINTREE)

        let result = try? MagnesSDK.shared().collectAndSubmit(withPayPalClientMetadataId: clientMetadataID ?? "",
                                                              withAdditionalData: data ?? [:])

        return result?.getPayPalClientMetaDataId() ?? ""
    }
    
    private func deviceIdentifier() -> String {
        // See if we already have an identifier in the keychain
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Service",
            kSecAttrAccount as String: "com.braintreepayments.Braintree-API.PayPal_MPL_DeviceGUID",
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess,
            let existingItem = item as? [String : Any],
            let data = existingItem[kSecValueData as String] as? Data,
            let identifier = String(data: data, encoding: String.Encoding.utf8) {
            return identifier
        }

        // If not, generate a new one and save it
        let newIdentifier = UUID().uuidString
        query[kSecValueData as String] = newIdentifier
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
        return newIdentifier
    }
}
