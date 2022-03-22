import Foundation

/// Mandate type for the SEPA Direct Debit request.
@objc public enum BTSEPADirectDebitMandateType: Int, CustomStringConvertible {

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

    static func getMandateType(from stringValue: String?) -> BTSEPADirectDebitMandateType? {
        switch stringValue {
        case BTSEPADirectDebitMandateType.oneOff.description:
            return .oneOff

        case BTSEPADirectDebitMandateType.recurrent.description:
            return .recurrent

        default:
            return nil
        }
    }
}
