import Foundation
import CardinalMobile

/// Render types that the device supports for displaying specific challenge user interfaces within
/// the 3D Secure challenge.
@objcMembers public class BTPaymentActionThreeDSecureRenderType: NSObject, OptionSet {

    public let rawValue: Int

    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// OTP
    public static let otp = BTPaymentActionThreeDSecureRenderType(rawValue: 1)

    /// HTML
    public static let html = BTPaymentActionThreeDSecureRenderType(rawValue: 2)

    /// Single select
    public static let singleSelect = BTPaymentActionThreeDSecureRenderType(rawValue: 3)

    /// Multi Select
    public static let multiSelect = BTPaymentActionThreeDSecureRenderType(rawValue: 4)

    /// OOB
    public static let oob = BTPaymentActionThreeDSecureRenderType(rawValue: 5)

    var cardinalValue: String? {
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
            return nil
        }
    }
}
