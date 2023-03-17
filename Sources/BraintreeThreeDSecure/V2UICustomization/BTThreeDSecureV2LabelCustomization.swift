import Foundation

/// Label customization options for 3D Secure 2 flows.
@objcMembers public class BTThreeDSecureV2LabelCustomization: BTThreeDSecureV2BaseCustomization {

    // MARK: - Public Properties

    /// Color code in Hex format. For example, the color code can be “#999999”.
    public var headingTextColor: String? {
        get { _headingTextColor }
        @objc(setHeadingTextColor:) set {
            _headingTextColor = newValue
            LabelCustomization().headingTextColor = newValue
        }
    }

    /// Font type for the heading label text.
    public var headingTextFontName: String? {
        get { _headingTextFontName }
        set { LabelCustomization().headingTextFontName = newValue }
    }

    /// Font size for the heading label text.
    public var headingTextFontSize: Int {
        get { _headingTextFontSize }
        set { LabelCustomization().headingTextFontSize = Int32(newValue) }
    }

    // MARK: - Private Properties

    /// Used as a holder for Obj-C interoperability
    private var _headingTextColor: String?

    /// Used as a holder for Obj-C interoperability
    private var _headingTextFontName: String?

    /// Used as a holder for Obj-C interoperability
    var _headingTextFontSize: Int = 0
}
