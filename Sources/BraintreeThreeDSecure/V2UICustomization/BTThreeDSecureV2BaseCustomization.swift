import Foundation
import CardinalMobile

/// Base customization options for 3D Secure 2 flows.
@objcMembers public class BTThreeDSecureV2BaseCustomization: NSObject {

    // MARK: - Public Properties

    /// Font type for the UI element.
    public var textFontName: String? {
        get { _textFontName }
        @objc(setTextFontName:) set {
            _textFontName = newValue
            cardinalValue?.textFontName = newValue
        }
    }

    /// Color code in Hex format. For example, the color code can be “#999999”.
    public var textColor: String? {
        get { _textColor }
        @objc(setTextColor:) set {
            _textColor = newValue
            cardinalValue?.textColor = newValue
        }
    }

    /// Font size for the UI element.
    public var textFontSize: Int {
        get { _textFontSize }
        @objc(setTextFontSize:) set {
            _textFontSize = newValue
            cardinalValue?.textFontSize = Int32(newValue)
        }
    }

    // MARK: - Internal Properties

    var cardinalValue: Customization?

    // MARK: - Private Properties

    /// Used as a holder for Obj-C interoperability
    private var _textFontName: String?

    /// Used as a holder for Obj-C interoperability
    private var _textColor: String?

    /// Used as a holder for Obj-C interoperability
    private var _textFontSize: Int = 0
}
