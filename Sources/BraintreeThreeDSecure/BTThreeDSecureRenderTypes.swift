import Foundation

/// Render types that the device supports for displaying specific challenge user interfaces within the 3D Secure challenge.
@objcMembers public class BTThreeDSecureRenderTypes: NSObject {

    public typealias StringValue = String

    /// OTP
    public static let otp: StringValue = "CardinalSessionRenderTypeOTP"

    /// HTML
    public static let html: StringValue = "CardinalSessionRenderTypeHTML"

    /// Single select
    public static let singleSelect: StringValue = "CardinalSessionRenderTypeSingleSelect"

    /// Multi Select
    public static let multiSelect: StringValue = "CardinalSessionRenderTypeMultiSelect"

    /// OOB
    public static let oob: StringValue = "CardinalSessionRenderTypeOOB"
}
