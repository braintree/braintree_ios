import Foundation

/// Contains information specific to a merchant's Braintree integration
@objcMembers public class BTConfiguration: NSObject {

    /// The merchant account's configuration as a `BTJSON` object
    public let json: BTJSON

    /// The environment (production or sandbox)
    public var environment: String? {
        self.json["environment"].asString()
    }

    ///  Used to initialize a `BTConfiguration`
    /// - Parameter json: The `BTJSON` to initialize with
    @objc(initWithJSON:)
    public init(json: BTJSON) {
        self.json = json
    }
}
