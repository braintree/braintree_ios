import Foundation

///  Error details associated with SEPA Direct Debit.
enum BTSEPADirectDebitError: Error, CustomNSError, LocalizedError {

    /// Unknown error
    case unknown

    static var errorDomain: String {
        "com.braintreepayments.BTSEPADirectDebitErrorDomain"
    }

    var errorCode: Int {
        switch self {
        case .unknown:
            return 0
        }
    }

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occured. Please contact support."
        }
    }
}
