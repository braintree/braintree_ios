import Foundation

/// Label customization options for 3D Secure 2 flows.
@objcMembers public class BTThreeDSecureV2LabelCustomization: BTThreeDSecureV2BaseCustomization {

    /// Color code in Hex format. For example, the color code can be “#999999”.
    public var headingTextColor: String? {
        didSet {
            LabelCustomization().headingTextColor = headingTextColor
        }
    }

    /// Font type for the heading label text.
    public var headingTextFontName: String? {
        didSet {
            LabelCustomization().headingTextFontName = headingTextFontName
        }
    }

    /// Font size for the heading label text.
    public var headingTextFontSize: Int? {
        didSet {
            LabelCustomization().headingTextFontSize = Int32(headingTextFontSize ?? 0)
        }
    }
}
