import Foundation

///  Error details associated with SEPA Direct Debit.
enum SEPADirectDebitError: Int, Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    /// SEPA Direct Debit flow was canceled by the user.
    case webFlowCanceled

    /// SEPA Direct Debit presentation context misconfiguration.
    case presentationContextInvalid

    /// The URL returned from the web flow was invalid.
    case resultURLInvalid

    /// The result of the create mandate request was nil and no error was returned.
    case resultReturnedNil

    /// The approval URL is invalid.
    case approvalURLInvalid

    /// The web authentication session result was nil and no error was returned.
    case authenticationResultNil
    
    /// A body was not returned from the API during the request.
    case noBodyReturned

    static var errorDomain: String {
        "com.braintreepayments.SEPADirectDebitErrorDomain"
    }

    var errorCode: Int {
        rawValue
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."
            
        case .webFlowCanceled:
            return "SEPA Direct Debit flow was canceled by the user."
            
        case .presentationContextInvalid:
            return "The presentation context provided to the tokenize method was invalid or not provided."
            
        case .resultURLInvalid:
            return "The URL returned from the web flow result was invalid."

        case .resultReturnedNil:
            return "The result of the create mandate request was nil and no error was returned."
            
        case .approvalURLInvalid:
            return "The approval URL is invalid."
            
        case .authenticationResultNil:
            return "The web authentication session result was nil and no error was returned."
            
        case .noBodyReturned:
            return "A body was not returned from the API during the request."
        }
    }
}
