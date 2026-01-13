import Foundation
import CardinalMobile

/// Render types that the device supports for displaying specific challenge user interfaces within the 3D Secure challenge.
@objcMembers public class BTThreeDSecureRenderType: NSObject, OptionSet {

    public let rawValue: Int

    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// OTP
    public static let otp = BTThreeDSecureRenderType(rawValue: 1)

    /// HTML
    public static let html = BTThreeDSecureRenderType(rawValue: 2)

    /// Single select
    public static let singleSelect = BTThreeDSecureRenderType(rawValue: 3)

    /// Multi Select
    public static let multiSelect = BTThreeDSecureRenderType(rawValue: 4)

    /// OOB
    public static let oob = BTThreeDSecureRenderType(rawValue: 5)

    // TODO: figure out why the underlying enum from cardinal is not properly exposed
    var cardinalValue: String {
        switch self {
        case .otp:
            return "01"  // EMVCo 3-D Secure UI Type for text/OTP
        case .html:
            return "05"  // EMVCo 3-D Secure UI Type for HTML
        case .singleSelect:
            return "02"  // EMVCo 3-D Secure UI Type for single select
        case .multiSelect:
            return "03"  // EMVCo 3-D Secure UI Type for multi select
        case .oob:
            return "04"  // EMVCo 3-D Secure UI Type for OOB
        default:
            return ""
        }
    }
}
