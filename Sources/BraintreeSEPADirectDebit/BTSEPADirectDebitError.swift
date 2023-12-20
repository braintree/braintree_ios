import Foundation

///  Error details associated with SEPA Direct Debit.
public enum BTSEPADirectDebitError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. Unknown error
    case unknown

    /// 1. SEPA Direct Debit flow was canceled by the user.
    case webFlowCanceled

    /// 2. The URL returned from the web flow was invalid.
    case resultURLInvalid

    /// 3. The result of the create mandate request was nil and no error was returned.
    case resultReturnedNil

    /// 4. The approval URL is invalid.
    case approvalURLInvalid

    /// 5. The web authentication session result was nil and no error was returned.
    case authenticationResultNil
    
    /// 6. A body was not returned from the API during the request.
    case noBodyReturned

    /// 7. Unable to create BTSEPADirectDebitNonce
    case failedToCreateNonce

    /// 8. Deallocated BTSEPADirectDebitClient
    case deallocated

    public static var errorDomain: String {
        "com.braintreepayments.SEPADirectDebitErrorDomain"
    }

    public var errorCode: Int {
        rawValue
    }

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred. Please contact support."
            
        case .webFlowCanceled:
            return "SEPA Direct Debit flow was canceled by the user."

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

        case .failedToCreateNonce:
            return "Unable to create BTSEPADirectDebitNonce. Nonce was not returned from the tokenize method."

        case .deallocated:
            return "BTSEPADirectDebitClient has been deallocated."
        }
    }
}
