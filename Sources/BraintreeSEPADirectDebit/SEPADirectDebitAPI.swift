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
        let json: [String: Any] = [
            "sepa_debit": [
                "merchant_or_partner_customer_id": sepaDirectDebitRequest.customerID ?? "",
                "mandate_type": sepaDirectDebitRequest.mandateType?.description ?? "",
                "account_holder_name": sepaDirectDebitRequest.accountHolderName ?? "",
                "iban": sepaDirectDebitRequest.iban ?? "",
                "billing_address": [
                    "address_line_1": billingAddress?.streetAddress,
                    "address_line_2": billingAddress?.extendedAddress,
                    "admin_area_1": billingAddress?.locality,
                    "admin_area_2": billingAddress?.region,
                    "postal_code": billingAddress?.postalCode,
                    "country_code": billingAddress?.countryCodeAlpha2
                ]
            ],
            "merchant_account_id": sepaDirectDebitRequest.merchantAccountID ?? "",
            "cancel_url": sepaDirectDebitRequest.cancelURL,
            "return_url": sepaDirectDebitRequest.returnURL
        ]

        apiClient.post("v1/sepa_debit", parameters: json) { body, response, error in
            self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.api-request.create-mandate.started")
            if let error = error {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.api-request.create-mandate.error")
                completion(nil, error)
                return
            }

            guard let body = body else {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.api-request.create-mandate.no-body.error")
                completion(nil, SEPADirectDebitError.noBodyReturned)
                return
            }

            self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.api-request.create-mandate.success")
            let result = CreateMandateResult(json: body)
            completion(result, nil)
        }
    }

    func tokenize(createMandateResult: CreateMandateResult, completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void) {
        let json: [String: Any] = [
            "sepa_debit_account": [
                "last_4": createMandateResult.ibanLastFour,
                "merchant_or_partner_customer_id": createMandateResult.customerID,
                "bank_reference_token": createMandateResult.bankReferenceToken,
                "mandate_type": createMandateResult.mandateType
            ]
        ]

        apiClient.post("v1/payment_methods/sepa_debit_accounts", parameters: json) { body, response, error in
            self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.api-request.tokenize.started")
            if let error = error {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.api-request.tokenize.error")
                completion(nil, error)
                return
            }

            guard let body = body else {
                self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.api-request.tokenize.no-body.error")
                completion(nil, SEPADirectDebitError.noBodyReturned)
                return
            }

            self.apiClient.sendAnalyticsEvent("ios.sepa-direct-debit.api-request.tokenize.success")
            let result = BTSEPADirectDebitNonce(json: body)
            completion(result, nil)
        }
    }
}
