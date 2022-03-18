import Foundation

///  Error details associated with SEPA Direct Debit.
enum BTSEPADirectDebitError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown
    
    /// The result was invalid
    case invalidResult
    
    /// SEPA Direct Debit flow was canceled by the user.
    case webFlowCanceled

    static var errorDomain: String {
        "com.braintreepayments.BTSEPADirectDebitErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .unknown:
            return 0
            
        case .invalidResult:
            return 1
            
        case .webFlowCanceled:
            return 2
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."
            
        case .invalidResult:
            return "There was an error decoding a required field in the result."
            
        case .webFlowCanceled:
            return "SEPA Direct Debit flow was canceled by the user."
        }
    }
}
