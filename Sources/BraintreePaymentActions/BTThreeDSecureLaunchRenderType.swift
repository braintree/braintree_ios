import Foundation
import CardinalMobile

/// Render types that the device supports for displaying specific challenge user interfaces within
/// the 3D Secure challenge.
///
/// Deliberately duplicated from `BraintreeThreeDSecure`'s identical `BTThreeDSecureRenderType` rather
/// than shared, so this module's only dependency is the `CardinalMobile` binary — not the existing
/// `BraintreeThreeDSecure` module — keeping the Payment Actions drive path fully isolated from the existing 3DS flow.
@objcMembers public class BTThreeDSecureLaunchRenderType: NSObject, OptionSet {

    public let rawValue: Int

    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// OTP
    public static let otp = BTThreeDSecureLaunchRenderType(rawValue: 1)

    /// HTML
    public static let html = BTThreeDSecureLaunchRenderType(rawValue: 2)

    /// Single select
    public static let singleSelect = BTThreeDSecureLaunchRenderType(rawValue: 3)

    /// Multi Select
    public static let multiSelect = BTThreeDSecureLaunchRenderType(rawValue: 4)

    /// OOB
    public static let oob = BTThreeDSecureLaunchRenderType(rawValue: 5)

    var cardinalValue: String {
        switch self {
        case .otp:
            return CardinalSessionRenderTypeOTP
        case .html:
            return CardinalSessionRenderTypeHTML
        case .singleSelect:
            return CardinalSessionRenderTypeSingleSelect
        case .multiSelect:
            return CardinalSessionRenderTypeMultiSelect
        case .oob:
            return CardinalSessionRenderTypeOOB
        default:
            return ""
        }
    }
}
