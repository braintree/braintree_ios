#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreeDataCollector)
import BraintreeDataCollector
#endif

/// Used to initialize a local payment flow
@objcMembers public class BTLocalPaymentRequest: BTPaymentFlowRequest {
    
    // MARK: - Public Properties
    
    /// The type of payment.
    public var paymentType: String?
    
    ///  The country code of the local payment.
    ///
    ///  This value must be one of the supported country codes for a given local payment type listed at the link below. For local payments supported in multiple countries, this value may determine which banks are presented to the customer.
    ///
    /// https://developer.paypal.com/braintree/docs/guides/local-payment-methods/client-side-custom/ios/v5#invoke-payment-flow
    public var paymentTypeCountryCode: String?
    
    /// Optional: The address of the customer. An error will occur if this address is not valid.
    public var merchantAccountID: String?
    
    /// Optional: The address of the customer. An error will occur if this address is not valid.
    public var address: BTPostalAddress?
    
    /// The amount for the transaction.
    public var amount: String?
    
    /// Optional: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
    public var currencyCode: String?
    
    /// Optional: The merchant name displayed inside of the local payment flow.
    public var displayName: String?
    
    /// Optional: Payer email of the customer.
    public var email: String?
    
    /// Optional: Given (first) name of the customer.
    public var givenName: String?
    
    /// Optional: Surname (last name) of the customer.
    public var surname: String?
    
    /// Optional: Phone number of the customer.
    public var phone: String?
    
    ///  Indicates whether or not the payment needs to be shipped. For digital goods, this should be false. Defaults to false.
    public var isShippingAddressRequired: Bool = false
    
    /// Optional: Bank Identification Code of the customer (specific to iDEAL transactions).
    public var bic: String?
    
    public weak var localPaymentFlowDelegate: BTLocalPaymentRequestDelegate?
    
    // MARK: - Internal Properties
    
    var paymentID: String?
    weak var paymentFlowClientDelegate: BTPaymentFlowClientDelegate?
    var correlationID: String?
}

// MARK: - BTPaymentFlowRequestDelegate Protocol Conformance

extension BTLocalPaymentRequest: BTPaymentFlowRequestDelegate {

    /// :nodoc:
    public func handle(
        _ request: BTPaymentFlowRequest,
        client apiClient: BTAPIClient,
        paymentClientDelegate delegate: BTPaymentFlowClientDelegate
    ) {
        paymentFlowClientDelegate = delegate
        let localPaymentRequest = request as! BTLocalPaymentRequest
        
        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else { return }

            if let error {
                delegate.onPaymentComplete(nil, error: error)
            }

            let dataCollector = BTDataCollector(apiClient: apiClient)
            self.correlationID = dataCollector.clientMetadataID(nil)

            guard let configuration else {
                delegate.onPaymentComplete(nil, error: BTPaymentFlowError.fetchConfigurationFailed)
                return
            }
            
            if !configuration.isLocalPaymentEnabled {
                // TODO: - Audit logging throughout the SDK, this module uses it more than others.
                NSLog("%@ Enable PayPal for this merchant in the Braintree Control Panel to use Local Payments.", BTLogLevelDescription.string(for: .critical))
                delegate.onPaymentComplete(nil, error: BTPaymentFlowError.disabled)
                return
            } else if (localPaymentRequest.localPaymentFlowDelegate == nil) {
                NSLog("%@ BTLocalPaymentRequest localPaymentFlowDelegate can not be nil.", BTLogLevelDescription.string(for: .critical))
                delegate.onPaymentComplete(nil, error: BTPaymentFlowError.integration)
                return
            } else if (localPaymentRequest.amount == nil || (localPaymentRequest.paymentType == nil)) {
                NSLog("%@ BTLocalPaymentRequest amount and paymentType can not be nil.", BTLogLevelDescription.string(for: .critical))
                delegate.onPaymentComplete(nil, error: BTPaymentFlowError.integration)
                return
            }

            var params: [String: Any] = [
                "amount": localPaymentRequest.amount ?? "",
                "funding_source": localPaymentRequest.paymentType ?? "",
                "intent": "sale",
                "return_url": "\(BTCoreConstants.callbackURLScheme)://x-callback-url/braintree/local-payment/success",
                "cancel_url": "\(BTCoreConstants.callbackURLScheme)://x-callback-url/braintree/local-payment/cancel"
            ]

            if let countryCode = localPaymentRequest.paymentTypeCountryCode {
                params["payment_type_country_code"] = countryCode
            }

            // TODO - don't think we ned this chaos and constant nil checking
            if let address = localPaymentRequest.address {
                params["line1"] = address.streetAddress
                params["line2"] = address.extendedAddress
                params["city"] = address.locality
                params["state"] = address.region
                params["postal_code"] = address.postalCode
                params["country_code"] = address.countryCodeAlpha2
            }

            if let currencyCode = localPaymentRequest.currencyCode {
                params["currency_iso_code"] = currencyCode
            }

            if let givenName = localPaymentRequest.givenName {
                params["first_name"] = givenName
            }

            if let surname = localPaymentRequest.surname {
                params["last_name"] = surname
            }

            if let email = localPaymentRequest.email {
                params["payer_email"] = email
            }

            if let phone = localPaymentRequest.phone {
                params["phone"] = phone
            }

            if let merchantAccountID = localPaymentRequest.merchantAccountID {
                params["merchant_account_id"] = merchantAccountID
            }

            if let bic = localPaymentRequest.bic {
                params["bic"] = bic
            }

            var experienceProfile: [String: Any] = [
                "no_shipping": !localPaymentRequest.isShippingAddressRequired,
            ]

            if let displayName = localPaymentRequest.displayName {
                experienceProfile["brand_name"] = displayName
            }

            params["experience_profile"] = experienceProfile

            apiClient.post("v1/local_payments/create", parameters: params) { body, response, error in
                if let error {
                    if (error as NSError).code == BTCoreConstants.networkConnectionLostCode {
                        apiClient.sendAnalyticsEvent("ios.local-payment-methods.network-connection.failure")
                    }
                    
                    delegate.onPayment(with: nil, error: error)
                    return
                }
                
                if let paymentID = body?["paymentResource"]["paymentToken"].asString(),
                   let approvalURLString = body?["paymentResource"]["redirectUrl"].asString(),
                   let url = URL(string: approvalURLString) {
                    
                    self.localPaymentFlowDelegate?.localPaymentStarted(self, paymentID: paymentID, start: {
                        delegate.onPayment(with: url, error: error)
                    })
                } else {
                    NSLog("%@ Payment cannot be processed: the redirectUrl or paymentToken is nil.  Contact Braintree support if the error persists.", BTLogLevelDescription.string(for: .critical))
                    delegate.onPaymentComplete(nil, error: BTPaymentFlowError.appSwitchFailed)
                    return
                }
            }
        }
    }

    /// :nodoc:
    public func handleOpen(_ url: URL) {
        if url.host == "x-callback-url" && url.path.hasPrefix("/braintree/local-payment/cancel") {
            // canceled case
            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTPaymentFlowError.canceled(paymentFlowName()))
            
        } else {
            // success case
            var params: [String: Any] = [:]
            
            var paypalAccount: [String: Any] = [:]
            paypalAccount["response"] = ["webURL": url.absoluteString]
            paypalAccount["response_type"] = "web"
            paypalAccount["options"] = ["validate": false]
            paypalAccount["intent"] = "sale"

            if let correlationID {
                paypalAccount["correlation_id"] = correlationID
            }

            if let merchantAccountID {
                params["merchant_account_id"] = merchantAccountID
            }
            
            params["paypal_account"] = paypalAccount
            
            // TODO: - audit use of self throughout re-write
            let metadata = paymentFlowClientDelegate?.apiClient().metadata
            params["_meta"] = [
                "source": metadata?.sourceString,
                "integraton": metadata?.integrationString,
                "sessionId": metadata?.sessionID
            ]
            
            paymentFlowClientDelegate?.apiClient().post("/v1/payment_methods/paypal_accounts", parameters: params, completion: { [weak self] body, response, error in
                guard let self else { return }
                
                if let error {
                    if (error as NSError).code == BTCoreConstants.networkConnectionLostCode {
                        self.paymentFlowClientDelegate?.apiClient().sendAnalyticsEvent("ios.local-payment-methods.network-connection.failure")
                    }
                    
                    self.paymentFlowClientDelegate?.onPaymentComplete(nil, error: error)
                    return
                } else {
                    guard let body else {
                        self.paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTPaymentFlowError.noAccountData)
                        return
                    }
                    
                    guard let tokenizedLocalPayment = BTLocalPaymentResult(json: body) else {
                        self.paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTPaymentFlowError.failedToCreateNonce)
                        return
                    }
                    
                    self.paymentFlowClientDelegate?.onPaymentComplete(tokenizedLocalPayment, error: nil)
                }
            })
        }
    }

    /// :nodoc:
    public func paymentFlowName() -> String {
        let paymentType = paymentType?.lowercased() ??  "unknown"
        return "\(paymentType).local-payment"
    }
}
