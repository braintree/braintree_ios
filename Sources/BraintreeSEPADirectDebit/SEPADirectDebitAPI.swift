import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class SEPADirectDebitAPI {
    
    private let apiClient: BTAPIClient
    
    @objc(initWithAPIClient:)
    init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    func createMandate(
        sepaDirectDebitRequest: BTSEPADirectDebitRequest,
        completion: @escaping (CreateMandateResult?, Error?) -> Void
    ) {
        let billingAddress = sepaDirectDebitRequest.billingAddress

        let billingAddressDictionary: [String: String?] = [
            "address_line_1": billingAddress?.streetAddress,
            "address_line_2": billingAddress?.extendedAddress,
            "admin_area_1": billingAddress?.locality,
            "admin_area_2": billingAddress?.region,
            "postal_code": billingAddress?.postalCode,
            "country_code": billingAddress?.countryCodeAlpha2
        ]

        let sepaDebitDictionary: [String: Any] = [
            "merchant_or_partner_customer_id": sepaDirectDebitRequest.customerID ?? "",
            "mandate_type": sepaDirectDebitRequest.mandateType?.description ?? "",
            "account_holder_name": sepaDirectDebitRequest.accountHolderName ?? "",
            "iban": sepaDirectDebitRequest.iban ?? "",
            "billing_address": billingAddressDictionary
        ]

        let json: [String: Any] = [
            "sepa_debit": sepaDebitDictionary,
            "merchant_account_id": sepaDirectDebitRequest.merchantAccountID ?? "",
            "cancel_url": BTCoreConstants.callbackURLScheme + "://sepa/cancel",
            "return_url": BTCoreConstants.callbackURLScheme + "://sepa/success"
        ]

        apiClient.post("v1/sepa_debit", parameters: json) { body, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let body = body else {
                completion(nil, BTSEPADirectDebitError.noBodyReturned)
                return
            }

            let result = CreateMandateResult(json: body)
            completion(result, nil)
        }
    }

    func tokenize(createMandateResult: CreateMandateResult, completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void) {
        let sepaDebitAccountDictionary: [String: String?] = [
            "last_4": createMandateResult.ibanLastFour,
            "merchant_or_partner_customer_id": createMandateResult.customerID,
            "bank_reference_token": createMandateResult.bankReferenceToken,
            "mandate_type": createMandateResult.mandateType
        ]

        let json: [String: Any] = ["sepa_debit_account": sepaDebitAccountDictionary]

        apiClient.post("v1/payment_methods/sepa_debit_accounts", parameters: json) { body, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let body = body else {
                completion(nil, BTSEPADirectDebitError.noBodyReturned)
                return
            }

            let result = BTSEPADirectDebitNonce(json: body)
            completion(result, nil)
        }
    }
}
