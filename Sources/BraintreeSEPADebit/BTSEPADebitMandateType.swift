import Foundation

/// Mandate type for the SEPA Debit request.
@objc public enum BTSEPADebitMandateType: Int, CustomStringConvertible {

    case oneOff
    case recurrent

    public var description: String {
        switch self {
        case .oneOff:
            return "ONE_OFF"

        case .recurrent:
            return "RECURRENT"
        }
    }

    static func getMandateType(from stringValue: String?) -> BTSEPADebitMandateType? {
        switch stringValue {
        case BTSEPADebitMandateType.oneOff.description:
            return .oneOff

        case BTSEPADebitMandateType.recurrent.description:
            return .recurrent

        default:
            return nil
        }
    }
}
