import Foundation

/// The POST body for `v1/payment_methods/sepa_debit_accounts`
struct SEPADebitAccountsRequest: Encodable {

    private let createMandateResult: SEPADebitAccountRequest

    enum CodingKeys: String, CodingKey {
        case createMandateResult = "sepa_debit_account"
    }

    struct SEPADebitAccountRequest: Encodable {

        let last4: String?
        let merchantOrPartnerCustomerID: String?
        let bankReferenceToken: String?
        let mandateType: String?

        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case last4 = "last_4"
            case merchantOrPartnerCustomerID = "merchant_or_partner_customer_id"
            case bankReferenceToken = "bank_reference_token"
            case mandateType = "mandate_type"
        }
        // swiftlint:enable nesting
    }

    init(createMandateResult: CreateMandateResult) {
        self.createMandateResult = SEPADebitAccountRequest(
            last4: createMandateResult.ibanLastFour,
            merchantOrPartnerCustomerID: createMandateResult.customerID,
            bankReferenceToken: createMandateResult.bankReferenceToken,
            mandateType: createMandateResult.mandateType
        )
    }
}
