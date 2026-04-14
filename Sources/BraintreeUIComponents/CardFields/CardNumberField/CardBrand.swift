import SwiftUI

/// Card Fields credit card brand image
public enum CardBrand {
    case amex
    case dinersClub
    case discover
    case jcb
    case mastercard
    case unionPay
    case unknown
    case visa
    
    var image: Image {
        switch self {
        case .amex:
            Image("AmericanExpressLogo", bundle: .uiComponents)
        case .dinersClub:
            Image("CreditCardLogo", bundle: .uiComponents)
        case .discover:
            Image("DiscoverLogo", bundle: .uiComponents)
        case .jcb:
            Image("JCBLogo", bundle: .uiComponents)
        case .mastercard:
            Image("MastercardLogo", bundle: .uiComponents)
        case .unionPay:
            Image("UnionPayLogo", bundle: .uiComponents)
        case .visa:
            Image("VisaLogo", bundle: .uiComponents)
        case .unknown:
            Image("CreditCardLogo", bundle: .uiComponents)
        }
    }
}
