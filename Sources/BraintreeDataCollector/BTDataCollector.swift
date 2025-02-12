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

    private let apiClient: BTAPIClient

    ///  Initializes a `BTDataCollector` instance with a `BTAPIClient`.
    /// - Parameter apiClient: An instance of `BTAPIClient`
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
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
