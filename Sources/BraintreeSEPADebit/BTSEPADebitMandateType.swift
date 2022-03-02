import Foundation

@objc public enum BTSEPADebitMandateType: Int {
    case oneOff
    case recurrent
    
    var stringValue: String {
        switch self {
        case .oneOff:
            return "ONE_OFF"
            
        case .recurrent:
            return "RECURRENT"
        }
    }
}
