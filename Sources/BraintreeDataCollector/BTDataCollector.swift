import Foundation
import CoreLocation

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
    
    /// Set your fraud merchant id.
    /// - Parameter merchantID: The fraudMerchantID you have established with your Braintree account manager.
    /// - Note: If you do not call this method, a generic Braintree value will be used.
    public func setFraudMerchantID(_ merchantID: String) {
        fraudMerchantID = merchantID
        kount?.merchantID = Int(merchantID) ?? defaultKountMerchantID
    }
    
    ///  Collects device data based on your merchant configuration.
    ///
    /// We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
    /// calling it when the customer initiates checkout is also fine.
    /// Use the return value on your server, e.g. with `Transaction.sale`.
    /// - Parameter completion:  A completion block that returns a device data string that should be passed into server-side calls, such as `Transaction.sale`.
    public func collectDeviceData(_ completion: @escaping (String) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self = self else { return }
            guard let configuration = configuration else { return }
            
            if configuration.isKountEnabled {
                let braintreeEnvironment: BTDataCollectorEnvironment = self.environmentFromString(configuration.environment ?? "production")
                self.setDataCollectorEnvironment(as: self.collectorEnvironment(environment: braintreeEnvironment))
                
                guard let kountMerchantID = self.fraudMerchantID != nil ? self.fraudMerchantID : configuration.kountMerchantID else { return }
                self.kount?.merchantID = Int(kountMerchantID) ?? self.defaultKountMerchantID
                
                let deviceSessionID: String = self.generateSessionID()
                let dataDictionary: [String: String] = [
                    "device_session_id": deviceSessionID,
                    "fraud_merchant_id": kountMerchantID
                ]
                
                self.kount?.collect(forSession: deviceSessionID)
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: dataDictionary) else { return }
                guard let deviceData = String(data: jsonData, encoding: .utf8) else { return }

                completion(deviceData)
            }
        }
    }
    
    // MARK: Internal methods
    
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
}
