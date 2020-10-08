import PayPalDataCollector
import PayPalDataCollector.Private

public class FakePPDataCollector: PPDataCollector {
    public static var didGetClientMetadataID = false
    public static var lastClientMetadataId = ""
    public static var lastData: [AnyHashable: Any]? = [:]
    public static var lastBeaconState = false

    public override class func clientMetadataID(_ pairingID: String?) -> String {
        return generateClientMetadataID(pairingID, disableBeacon: false, data: nil)
    }

    public override class func generateClientMetadataID() -> String {
        return generateClientMetadataID(nil, disableBeacon: false, data: nil)
    }

    public override class func generateClientMetadataIDWithoutBeacon(_ clientMetadataID: String?, data: [AnyHashable : Any]?) -> String {
        return generateClientMetadataID(clientMetadataID, disableBeacon: true, data: data)
    }

    public override class func generateClientMetadataID(_ clientMetadataID: String?, disableBeacon: Bool, data: [AnyHashable : Any]?) -> String {
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

    public class func resetState() -> Void {
        lastBeaconState = false
        didGetClientMetadataID = false
        lastData = nil
        lastClientMetadataId = ""
    }
}
