import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

// swiftlint:disable nesting
/// The POST body for `v1/sepa_debit`
struct SEPADebitRequest: Encodable {

    let merchantAccountID: String?
    let cancelURL: String?
    let returnURL: String?
    let locale: String?

    private let sepaAccountRequest: SEPAAccountRequest

    enum CodingKeys: String, CodingKey {
        case sepaAccountRequest = "sepa_debit"
        case merchantAccountID = "merchant_account_id"
        case cancelURL = "cancel_url"
        case returnURL = "return_url"
        case locale = "locale"
    }

    struct SEPAAccountRequest: Encodable {

        let merchantOrPartnerCustomerID: String?
        let mandateType: String?
        let accountHolderName: String?
        let iban: String?
        let billingAddress: BillingAddress?

        enum CodingKeys: String, CodingKey {
            case merchantOrPartnerCustomerID = "merchant_or_partner_customer_id"
            case mandateType = "mandate_type"
            case accountHolderName = "account_holder_name"
            case iban = "iban"
            case billingAddress = "billing_address"
        }

        struct BillingAddress: Encodable {

            let streetAddress: String?
            let extendedAddress: String?
            let locality: String?
            let region: String?
            let postalCode: String?
            let countryCodeAlpha2: String?

            enum CodingKeys: String, CodingKey {
                case streetAddress = "address_line_1"
                case extendedAddress = "address_line_2"
                case locality = "admin_area_1"
                case region = "admin_area_2"
                case postalCode = "postal_code"
                case countryCodeAlpha2 = "country_code"
            }
        }
        // swiftlint:enable nesting

        init(sepaDirectDebitRequest: BTSEPADirectDebitRequest) {
            self.merchantOrPartnerCustomerID = sepaDirectDebitRequest.customerID
            self.mandateType = sepaDirectDebitRequest.mandateType?.description
            self.accountHolderName = sepaDirectDebitRequest.accountHolderName
            self.iban = sepaDirectDebitRequest.iban
            self.billingAddress = BillingAddress(
                streetAddress: sepaDirectDebitRequest.billingAddress?.streetAddress,
                extendedAddress: sepaDirectDebitRequest.billingAddress?.extendedAddress,
                locality: sepaDirectDebitRequest.billingAddress?.locality,
                region: sepaDirectDebitRequest.billingAddress?.region,
                postalCode: sepaDirectDebitRequest.billingAddress?.postalCode,
                countryCodeAlpha2: sepaDirectDebitRequest.billingAddress?.countryCodeAlpha2
            )
        }
    }

    init(sepaDirectDebitRequest: BTSEPADirectDebitRequest) {
        self.sepaAccountRequest = SEPAAccountRequest(sepaDirectDebitRequest: sepaDirectDebitRequest)
        self.merchantAccountID = sepaDirectDebitRequest.merchantAccountID
        self.cancelURL = BTCoreConstants.callbackURLScheme + "://sepa/cancel"
        self.returnURL = BTCoreConstants.callbackURLScheme + "://sepa/success"
        self.locale = sepaDirectDebitRequest.locale
    }
}
