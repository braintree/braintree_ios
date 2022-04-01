import PPRiskMagnes
import Security

/**
 Enables you to collect data about a customer's device and correlate it with a session identifier on your server.
 */
@objc public class PPDataCollector: NSObject {

    /**
     Returns a client metadata ID.

     - Note This returns a raw client metadata ID, which is not the correct format for device data
     when creating a transaction. Instead, it is recommended to use `collectPayPalDeviceData`.

     - Parameter pairingID: A pairing ID to associate with this clientMetadataID must be 10-32 chars long or null
     - Returns: A client metadata ID to send as a header
     */
    @objc public class func clientMetadataID(_ pairingID: String?) -> String {
        clientMetadataID(pairingID, isSandbox: false)
    }

    /// Returns a client metadata ID.
    /// - Parameters:
    ///   - pairingID: A pairing ID to associate with this clientMetadataID must be 10-32 chars long or null.
    ///   - isSandbox: If true, the request will be sent to the sandbox environment. If false the request will be sent to the production environment.
    /// - Returns: A client metadata ID to send as a header
    /// - Note: This returns a raw client metadata ID, which is not the correct format for device data when creating a transaction. Instead, it is recommended to use `collectPayPalDeviceData`.
    // NEXT_MAJOR_VERSION: remove this function and have this module depend on core + pass in BTAPIClient
    @objc public class func clientMetadataID(_ pairingID: String?, isSandbox: Bool) -> String {
        PPDataCollector.generateClientMetadataID(pairingID, disableBeacon: false, isSandbox: isSandbox, data: nil)
    }

    /**
     Collects device data.

     - Returns: A JSON string containing a device data identifier that should be passed into server-side calls, such as `Transaction.sale`.
    */
    @objc public class func collectPayPalDeviceData() -> String {
        collectPayPalDeviceData(isSandbox: false)
    }

    /// Collects device data.
    /// - Parameter isSandbox: If true, the request will be sent to the sandbox environment. If false the request will be sent to the production environment.
    /// - Returns: A JSON string containing a device data identifier that should be passed into server-side calls, such as `Transaction.sale`.
    // NEXT_MAJOR_VERSION: remove this function and have this module depend on core + pass in BTAPIClient
    @objc public class func collectPayPalDeviceData(isSandbox: Bool) -> String {
        "{\"correlation_id\":\"\(PPDataCollector.generateClientMetadataID(isSandbox: isSandbox))\"}"
    }

    // NEXT_MAJOR_VERSION: remove isSandbox and have this module depend on core + pass in BTAPIClient - get the env from the configuration and switch the env based on the config
    @objc class func generateClientMetadataID(_ clientMetadataID: String?, disableBeacon: Bool, isSandbox: Bool, data: [String : String]?) -> String {
        try? MagnesSDK.shared().setUp(setEnviroment: isSandbox ? .SANDBOX : .LIVE,
                                      setOptionalAppGuid: PPDataCollector.deviceIdentifier(),
                                      disableRemoteConfiguration: false,
                                      disableBeacon: disableBeacon,
                                      magnesSource: .BRAINTREE)

        let result = try? MagnesSDK.shared().collectAndSubmit(withPayPalClientMetadataId: clientMetadataID ?? "",
                                                              withAdditionalData: data ?? [:])

        return result?.getPayPalClientMetaDataId() ?? ""
    }

    @objc class func generateClientMetadataID(isSandbox: Bool) -> String {
        return PPDataCollector.generateClientMetadataID("", disableBeacon: false, isSandbox: false, data: nil)
    }

    private static func deviceIdentifier() -> String {
        // See if we already have an identifier in the keychain
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Service",
                                    kSecAttrAccount as String: "com.braintreepayments.Braintree-API.PayPal_MPL_DeviceGUID",
                                    kSecReturnData as String: true]

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
