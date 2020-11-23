import PayPalDataCollector

@objc public class FakePPDataCollector: NSObject {
    public static var didGetClientMetadataID = false
    public static var lastClientMetadataId = ""
    public static var lastData: [AnyHashable: Any]? = [:]
    public static var lastBeaconState = false

    @objc public class func clientMetadataID(_ pairingID: String?) -> String {
        return generateClientMetadataID(pairingID, disableBeacon: false, data: nil)
    }

    @objc class func generateClientMetadataID() -> String {
        return generateClientMetadataID(nil, disableBeacon: false, data: nil)
    }

    @objc class func generateClientMetadataIDWithoutBeacon(_ clientMetadataID: String?, data: [String : String]?) -> String {
        return generateClientMetadataID(clientMetadataID, disableBeacon: true, data: data)
    }

    @objc class func generateClientMetadataID(_ clientMetadataID: String?, disableBeacon: Bool, data: [String : String]?) -> String {
        if (data != nil) {
            lastData = data!
        } else {
            lastData = nil
        }
        if (clientMetadataID != nil) {
            lastClientMetadataId = clientMetadataID!
        } else {
            lastClientMetadataId = "fakeclientmetadataid"
        }
        lastBeaconState = disableBeacon
        didGetClientMetadataID = true
        return lastClientMetadataId
    }

    class func resetState() -> Void {
        lastBeaconState = false
        didGetClientMetadataID = false
        lastData = nil
        lastClientMetadataId = ""
    }
}
