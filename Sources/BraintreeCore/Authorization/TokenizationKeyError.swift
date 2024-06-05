import Foundation

///  Error codes associated with a Tokenization Key.
public enum TokenizationKeyError: Int, Error, CustomNSError, LocalizedError, Equatable {

    /// 0. The tokenization key provided was invalid
    case invalid

    public static var errorDomain: String {
        "com.braintreepayments.BTTokenizationKeyErrorDomain"
    }

    public var errorCode: Int {
        rawValue
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalid:
            return "Invalid tokenization key. Please ensure your server is generating a valid Braintree Tokenization Key."
        }
    }
}

