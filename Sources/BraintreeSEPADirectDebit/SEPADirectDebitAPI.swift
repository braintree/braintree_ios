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
        let json: [String: Any] = [
            "sepa_debit": [
                "merchant_or_partner_customer_id": sepaDirectDebitRequest.customerID ?? "",
                "mandate_type": sepaDirectDebitRequest.mandateType?.rawValue ?? "",
                "account_holder_name": sepaDirectDebitRequest.accountHolderName ?? "",
                "iban": sepaDirectDebitRequest.iban ?? "",
                "merchant_account_id": sepaDirectDebitRequest.merchantAccountID ?? "",
                "cancel_url": sepaDirectDebitRequest.cancelURL,
                "return_url": sepaDirectDebitRequest.returnURL,
                "billing_address": [
                    "address_line_1": sepaDirectDebitRequest.billingAddress?.streetAddress,
                    "address_line_2": sepaDirectDebitRequest.billingAddress?.extendedAddress,
                    "admin_area_1": sepaDirectDebitRequest.billingAddress?.locality,
                    "admin_area_2": sepaDirectDebitRequest.billingAddress?.region,
                    "postal_code": sepaDirectDebitRequest.billingAddress?.postalCode,
                    "country_code": sepaDirectDebitRequest.billingAddress?.countryCodeAlpha2
                ]
            ]
        ]
        
        apiClient.post("v1/sepa_debit", parameters: json) { body, response, error in
            if let error = error {
                // TODO: send analytics
                completion(nil, error)
                return
            }
            
            guard let body = body else {
                // TODO: send analytics
                // TODO: send error here
                 completion(nil, nil)
                 return
             }
            
            let result = CreateMandateResult(json: body)
            completion(result, nil)
            
        }
    }
    
    func tokenize(createMandateResult: CreateMandateResult, completion: @escaping (BTSEPADirectDebitNonce?, Error?) -> Void) {
        let json: [String: Any] = [
            "sepa_debit_account": [
                "iban_last_chars": createMandateResult.ibanLastFour,
                "merchant_or_partner_customer_id": createMandateResult.customerID,
                "bank_reference_token": createMandateResult.bankReferenceToken,
                "mandate_type": createMandateResult.mandateType
            ]
        ]
        
        apiClient.post("client_api/v1/payment_methods/sepa_debit_accounts", parameters: json) { body, response, error in
            if let error = error {
                // TODO: send analytics
                completion(nil, error)
                return
            }
            
            guard let body = body else {
                // TODO: send analytics
                // TODO: send error here
                 completion(nil, nil)
                 return
             }
            
            let result = BTSEPADirectDebitNonce(json: body)
            completion(result, nil)
            
        }
    }
}
