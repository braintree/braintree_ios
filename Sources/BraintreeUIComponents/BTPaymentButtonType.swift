import SwiftUI

enum BTPaymentButtonType {
    case primary
    case black
    case white

    var imageName: ImageResource {
        switch self {
        case .primary:
            return .payPalLogoBlack
        case .black:
            return .payPalLogoWhite
        case .white:
            return .payPalLogoBlack
        }
    }

    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color(red: 96 / 255, green: 205 / 255, blue: 255 / 255)
        case .black:
            return .black
        case .white:
            return .white
        }
    }

    var hasOutline: Bool {
        switch self {
        case .primary:
            return false
        case .black:
            return false
        case .white:
            return true
        }
    }
}
