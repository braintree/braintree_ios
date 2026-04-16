import Foundation

enum CardBrand: CaseIterable {
    case visa
    case mastercard
    case amex
    case discover
    case jcb
    case dinersClub
    case unionPay
    case maestro
    case hiper
    case hipercard
    case unknown

    // MARK: - Prefix Patterns

    /// Strict prefix patterns checked first across all brands before relaxed patterns.
    /// Order of cases in CaseIterable matters — Discover must come before UnionPay
    /// to correctly handle the 622126–622925 co-branded range.
    var prefixPatterns: [Regex<Substring>] {
        switch self {
        case .visa:
            return [#/4\d*/#]
        case .mastercard:
            return [#/(?:5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[0-1]|2720)\d*/#]
        case .amex:
            return [#/3[47]\d*/#]
        case .discover:
            // 622 prefix checked here before UnionPay's broader 62 to handle co-branded range
            return [#/(?:6011|65|64[4-9]|622)\d*/#]
        case .jcb:
            return [#/35\d*/#]
        case .dinersClub:
            return [#/(?:36|38|30[0-5])\d*/#]
        case .unionPay:
            return [#/62\d*/#]
        case .maestro:
            return [#/(?:5018|5020|5038|5[6-9]|6020|6304|6703|6759|676[1-3])\d*/#]
        case .hiper:
            return [#/637(?:095|568|599|609|612)\d*/#]
        case .hipercard:
            return [#/606282\d*/#]
        case .unknown:
            return []
        }
    }

    /// Relaxed prefix patterns only used if no strict match is found across all brands.
    /// Only Maestro uses relaxed matching — mirrors the drop-in's two-pass detection.
    var relaxedPrefixPatterns: [Regex<Substring>] {
        switch self {
        case .maestro:
            return [#/6\d*/#]
        default:
            return []
        }
    }

    // MARK: - Length Rules

    var validLengths: Set<Int> {
        switch self {
        case .amex:
            return [15]
        case .dinersClub:
            return [14]
        case .discover:
            return [16, 17, 18, 19]
        case .maestro:
            return [12, 13, 14, 15, 16, 17, 18, 19]
        case .unionPay:
            return [16, 17, 18, 19]
        default:
            return [16]
        }
    }

    var minLength: Int {
        validLengths.min() ?? 16
    }

    var maxLength: Int {
        validLengths.max() ?? 16
    }

    // MARK: - CVV

    var cvvLength: Int {
        self == .amex ? 4 : 3
    }
}
