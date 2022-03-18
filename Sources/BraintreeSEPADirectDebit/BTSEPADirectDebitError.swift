import Foundation

///  Error details associated with SEPA Direct Debit.
enum BTSEPADirectDebitError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown
    
    /// The result was invalid
    case invalidResult

    static var errorDomain: String {
        "com.braintreepayments.BTSEPADirectDebitErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .unknown:
            return 0
            
        case .invalidResult:
            return 1
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."
            
        case .invalidResult:
            return "There was an error decoding a required field in the result."
        }
    }
}
