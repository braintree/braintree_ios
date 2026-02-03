import Foundation
import CoreLocation
import PPRiskMagnes
import Security

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Braintree's advanced fraud protection solution.
@objc public class BTDataCollector: NSObject {
    
    var config: BTConfiguration?

    var apiClient: BTAPIClient

    ///  Initializes a `BTDataCollector` instance.
    /// - Parameter  authorization: A valid client token or tokenization key used to authorize API calls.
    @objc(initWithAuthorization:)
    public init(authorization: String) {
        self.apiClient = BTAPIClient(authorization: authorization)
    }
    
    // MARK: Public methods
    
    /// Returns a client metadata ID.
    /// - Parameter pairingID: A pairing ID to associate with this clientMetadataID must be 10-32 chars long or null
    /// - Returns: A client metadata ID to send as a header
    /// - Note: This returns a raw client metadata ID, which is not the correct format for device data when creating a transaction. Instead, it is recommended to use `collectDeviceData`.
    @objc public func clientMetadataID(_ pairingID: String?) -> String {
        generateClientMetadataID(pairingID, disableBeacon: false, configuration: nil, data: nil)
    }
    
    /// Collects device data based on your merchant configuration.
    ///
    ///  We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
    ///  calling it when the customer initiates checkout is also fine.
    ///  Use the return value on your server, e.g. with `Transaction.sale`.
    ///  - Parameter completion:  A completion block that returns either a device data string that should be passed into server-side calls, such as `Transaction.sale`, or an error with the failure reason.
    @objc public func collectDeviceData(_ completion: @escaping (String?, Error?) -> Void) {
        fetchConfiguration { configuration, error in
            guard let configuration = configuration else {
                completion(nil, error)
                return
            }
            
            let clientMetadataID: String = self.generateClientMetadataID(with: configuration)
            let dataDictionary: [String: String] = ["correlation_id": clientMetadataID]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dataDictionary) else {
                completion(nil, BTDataCollectorError.jsonSerializationFailure)
                return
            }
            
            guard let deviceData = String(data: jsonData, encoding: .utf8) else {
                completion(nil, BTDataCollectorError.encodingFailure)
                return
            }
            
            completion(deviceData, nil)
        }
    }

    /// Collects device data based on your merchant configuration.
    ///
    ///  We recommend that you call this method as early as possible, e.g. at app launch. If that's too early,
    ///  calling it when the customer initiates checkout is also fine.
    ///  Use the return value on your server, e.g. with `Transaction.sale`.
    /// - Returns: A device data string that should be passed into server-side calls, such as `Transaction.sale`.
    /// - Throws: An `Error` describing the failure
    public func collectDeviceData() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            collectDeviceData { deviceData, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let deviceData {
                    continuation.resume(returning: deviceData)
                }
            }
        }
    }

    /// This method should be used for markets where high coverage of device data
    /// is needed (ex: Predictions Market). Collects device data based on
    /// your merchant configuration.
    ///
    /// We recommend that you call this method as early as possible, e.g. at app
    /// launch. If that's too early, calling it when the customer initiates checkout
    /// is also fine. When using this method you should only proceed if a success is
    /// returned. In cases where an error is returned, retrying this method is recommended.
    ///
    /// Use the return value on your server, e.g. with `Transaction.sale`. or in
    /// client side requests such as PayPal, Venmo, or Local Payment Methods.
    /// - Parameters:
    ///   - riskCorrelationID: A risk correlation ID to associate with this device data collection
    ///   - completion: A completion block that returns either a device data string or an error with the failure reason. Retries are recommended on failure.
    @objc public func collectDeviceDataOnSuccess(
        riskCorrelationID: String,
        _ completion: @escaping (String?, Error?) -> Void
    ) {
        fetchConfiguration { configuration, error in
            guard let configuration else {
                completion(nil, error)
                return
            }

            self.config = configuration

            let magnesEnvironment = self.getMagnesEnvironment(from: self.config)

            try? MagnesSDK.shared().setUp(
                setEnviroment: magnesEnvironment,
                setOptionalAppGuid: self.deviceIdentifier(),
                disableRemoteConfiguration: false,
                disableBeacon: false,
                magnesSource: .BRAINTREE
            )

            _ = try? MagnesSDK.shared().collectAndSubmit(
                withPayPalClientMetadataId: riskCorrelationID,
                withAdditionalData: [:]
            ) { status, clientMetadataID in
                switch status {
                case .success:
                    guard let clientMetadataID else {
                        completion(nil, BTDataCollectorError.callbackSubmitError)
                        return
                    }

                    let data: [String: String] = ["correlation_id": clientMetadataID]

                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
                        completion(nil, BTDataCollectorError.jsonSerializationFailure)
                        return
                    }

                    guard let deviceData = String(data: jsonData, encoding: .utf8) else {
                        completion(nil, BTDataCollectorError.encodingFailure)
                        return
                    }

                    completion(deviceData, nil)

                case .error:
                    completion(nil, BTDataCollectorError.callbackSubmitError)

                case .timeout:
                    completion(nil, BTDataCollectorError.callbackSubmitTimeout)

                @unknown default:
                    completion(nil, BTDataCollectorError.unknown)
                }
            }
        }
    }

    /// This method should be used for markets where high coverage of device data
    /// is needed (ex: Predictions Market). Collects device data based on
    /// your merchant configuration.
    ///
    /// We recommend that you call this method as early as possible, e.g. at app
    /// launch. If that's too early, calling it when the customer initiates checkout
    /// is also fine. When using this method you should only proceed if a success is
    /// returned. In cases where an error is returned, retrying this method is recommended.
    ///
    /// Use the return value on your server, e.g. with `Transaction.sale`. or in
    /// client side requests such as PayPal, Venmo, or Local Payment Methods.
    /// - Parameters:
    ///  - completion: A completion block that returns either a device data string or an error with the failure reason. Retries are recommended on failure.
    ///  - riskCorrelationID: A risk correlation ID to associate with this device data collection
    /// - Returns: A device data string that should be passed into server-side calls, such as `Transaction.sale`.
    /// - Throws: An `Error` describing the failure or timeout. Merchants should retry on error to ensure coverage.
    public func collectDeviceDataOnSuccess(riskCorrelationID: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            collectDeviceDataOnSuccess(riskCorrelationID: riskCorrelationID) { deviceData, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let deviceData {
                    continuation.resume(returning: deviceData)
                }
            }
        }
    }

    // MARK: Internal methods
    
    func fetchConfiguration(completion: @escaping (BTConfiguration?, Error?) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            completion(configuration, error)
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
    
    func generateClientMetadataID(
        _ clientMetadataID: String?,
        disableBeacon: Bool,
        configuration: BTConfiguration?,
        data: [String: String]?
    ) -> String {
        if configuration != nil {
            config = configuration
        } else {
            fetchConfiguration { configuration, _ in
                self.config = configuration
            }
        }

        let mangnesEnvironment = getMagnesEnvironment(from: config)

        try? MagnesSDK.shared().setUp(
            setEnviroment: mangnesEnvironment,
            setOptionalAppGuid: deviceIdentifier(),
            disableRemoteConfiguration: false,
            disableBeacon: disableBeacon,
            magnesSource: .BRAINTREE
        )

        let result = try? MagnesSDK.shared().collectAndSubmit(
            withPayPalClientMetadataId: clientMetadataID ?? "",
            withAdditionalData: data ?? [:]
        )

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
            let data = item as? Data,
            let identifier = String(data: data, encoding: .utf8) {
            return identifier
        }

        // If not, generate a new one and save it
        let newIdentifier = UUID().uuidString
        query[kSecValueData as String] = newIdentifier.data(using: .utf8)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
        return newIdentifier
    }
}
