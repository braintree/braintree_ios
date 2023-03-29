import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePaymentFlow)
import BraintreePaymentFlow
#endif

/// Used to initialize a 3D Secure payment flow
@objcMembers public class BTThreeDSecureRequestSwift: BTPaymentFlowRequest {
    
    // MARK: - Public Properties

    /// A nonce to be verified by ThreeDSecure
    public let nonce: String

    /// The amount for the transaction
    public let amount: Decimal

    /// Optional. The account type selected by the cardholder
    /// - Note: Some cards can be processed using either a credit or debit account and cardholders have the option to choose which account to use.
    public let accountType: BTThreeDSecureAccountTypeSwift

    /// Optional. The billing address used for verification
    public let billingAddress: BTThreeDSecurePostalAddress?

    /// Optional. The mobile phone number used for verification
    /// - Note: Only numbers. Remove dashes, parentheses and other characters
    public let mobilePhoneNumber: String?

    /// Optional. The email used for verification
    public let email: String?

    /// Optional. The shipping method chosen for the transaction
    public let shippingMethod: BTThreeDSecureShippingMethodSwift

    /// Optional. The additional information used for verification
    public let additionalInformation: BTThreeDSecureAdditionalInformation?

    /// Optional. If set to true, an authentication challenge will be forced if possible.
    public let challengeRequested: Bool?

    /// Optional. If set to true, an exemption to the authentication challenge will be requested.
    public let exemptionRequested: Bool?

    /// Optional. The exemption type to be requested. If an exemption is requested and the exemption's conditions are satisfied, then it will be applied.
    public let requestedExemptionType: BTThreeDSecureRequestedExemptionTypeSwift

    /// :nodoc:
    // TODO: do we need a doc string for this?
    public let dataOnlyRequested: Bool?

    /// Optional. An authentication created using this property should only be used for adding a payment method to the merchant's vault and not for creating transactions.
    ///
    /// Defaults to `.unspecified.`
    ///
    /// If set to `.challengeRequested`, the authentication challenge will be requested from the issuer to confirm adding new card to the merchant's vault.
    /// If set to `.notRequested` the authentication challenge will not be requested from the issuer.
    /// If set to `.unspecified`, when the amount is 0, the authentication challenge will be requested from the issuer.
    /// If set to `.unspecified`, when the amount is greater than 0, the authentication challenge will not be requested from the issuer.
    public let cardAddChallenge: BTThreeDSecureCardAddChallenge?

    /// Optional. UI Customization for 3DS2 challenge views.
    public let v2UICustomization: BTThreeDSecureV2UICustomization?

    /// A delegate for receiving information about the ThreeDSecure payment flow.
    public weak var threeDSecureRequestDelegate: BTThreeDSecureRequestDelegate?
    
    // MARK: - Internal Properties

    /// Set the BTPaymentFlowClientDelegate for handling the client events.
    weak var paymentFlowClientDelegate: BTPaymentFlowClientDelegate?

    /// The dfReferenceID for the session. Exposed for testing.
    var dfReferenceID: String = ""

    var threeDSecureV2Provider: BTThreeDSecureV2Provider?
    
    // MARK: - Initializer
    
    public init(
        nonce: String,
        amount: Decimal,
        accountType: BTThreeDSecureAccountTypeSwift = .unspecified,
        billingAddress: BTThreeDSecurePostalAddress? = nil,
        mobilePhoneNumber: String? = nil,
        email: String? = nil,
        shippingMethod: BTThreeDSecureShippingMethodSwift = .unspecified,
        additionalInformation: BTThreeDSecureAdditionalInformation? = nil,
        challengeRequested: Bool? = nil,
        exemptionRequested: Bool? = nil,
        requestedExemptionType: BTThreeDSecureRequestedExemptionTypeSwift = .unspecified,
        dataOnlyRequested: Bool? = nil,
        cardAddChallenge: BTThreeDSecureCardAddChallenge? = nil,
        v2UICustomization: BTThreeDSecureV2UICustomization? = nil,
        threeDSecureRequestDelegate: BTThreeDSecureRequestDelegate? = nil
    ) {
        self.nonce = nonce
        self.amount = amount
        self.accountType = accountType
        self.billingAddress = billingAddress
        self.mobilePhoneNumber = mobilePhoneNumber
        self.email = email
        self.shippingMethod = shippingMethod
        self.additionalInformation = additionalInformation
        self.challengeRequested = challengeRequested
        self.exemptionRequested = exemptionRequested
        self.requestedExemptionType = requestedExemptionType
        self.dataOnlyRequested = dataOnlyRequested
        self.cardAddChallenge = cardAddChallenge
        self.v2UICustomization = v2UICustomization
        self.threeDSecureRequestDelegate = threeDSecureRequestDelegate
    }
    
    // MARK: - Internal Methods
    
    // TODO: maybe pass config in?
    /// Prepare for a 3DS 2.0 flow.
    /// - Parameters:
    ///   - apiClient: The API client.
    ///   - completion: This completion will be invoked exactly once. If the error is nil then the preparation was successful.
    func prepareLookup(apiClient: BTAPIClient, completion: @escaping (Error?) -> Void) {
        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            guard let configuration, error == nil else {
                completion(error)
                return
            }

            if configuration.cardinalAuthenticationJWT != nil {
                // TODO: uncomment after removing Obj-C files
//                self.threeDSecureV2Provider = BTThreeDSecureV2Provider(
//                    configuration: configuration,
//                    apiClient: apiClient,
//                    request: self
//                ) { lookupParameters in
//                    if let dfReferenceID = lookupParameters?["dfReferenceId"] {
//                        self.dfReferenceID = dfReferenceID
//                        completion(nil)
//                    }
//                }
            } else {
                completion(BTThreeDSecureError.configuration)
                return
            }
        }
    }
    
    func processLookupResult(lookupResult: BTThreeDSecureResult, configuration: BTConfiguration) {
        
    }
    
    // MARK: - Private Methods
    
    private func startRequest(request: BTPaymentFlowRequest, configuration: BTConfiguration) {
        
    }
    
    private func performV2Authentication(lookupResult: BTThreeDSecureResult) {
        
    }
    
    private func logThreeDSecureCompletedAnalytics(forResult result: BTThreeDSecureResult, apiClient: BTAPIClient) {
        let liabilityShiftPossible = result.tokenizedCard?.threeDSecureInfo.liabilityShiftPossible ?? false
        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.liability-shift-possible.\(stringFor(liabilityShiftPossible))")
    }
    
    func stringFor(_ boolean: Bool) -> String {
        boolean ? "true" : "false"
    }
}

// MARK: - BTPaymentFlowRequestDelegate Protocol Conformance

extension BTThreeDSecureRequestSwift: BTPaymentFlowRequestDelegate {

    public func handle(
        _ request: BTPaymentFlowRequest,
        client apiClient: BTAPIClient,
        paymentClientDelegate delegate: BTPaymentFlowClientDelegate
    ) {
        paymentFlowClientDelegate = delegate

        apiClient.sendAnalyticsEvent("ios.three-d-secure.initialized")

        apiClient.fetchOrReturnRemoteConfiguration { configuration, configurationError in
            if let configurationError {
                self.paymentFlowClientDelegate?.onPaymentComplete(nil, error: configurationError)
                return
            }

            var integrationError: NSError?

            if (configuration?.cardinalAuthenticationJWT == nil) {
                NSLog("%@ BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly.", BTLogLevelDescription.string(for: .critical)  ?? "[BraintreeSDK] CRITICAL")
                integrationError = NSError(
                    domain: BTThreeDSecureFlowErrorDomain,
                    // TODO: - Create Error enum for 3DS module
                    code: BTThreeDSecureFlowErrorType.configuration.rawValue,
                    userInfo: [NSLocalizedDescriptionKey: "BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly."]
                )
            }

            if (self.amount.isNaN) {
                NSLog("%@ BTThreeDSecureRequest amount can not be NaN.", BTLogLevelDescription.string(for: .critical)  ?? "[BraintreeSDK] CRITICAL")
                integrationError = NSError(
                    domain: BTThreeDSecureFlowErrorDomain,
                    // TODO: - Create Error enum for 3DS module
                    code: BTThreeDSecureFlowErrorType.configuration.rawValue,
                    userInfo: [NSLocalizedDescriptionKey: "BTThreeDSecureRequest amount can not be NaN."]
                )
            }

            if let integrationError {
                delegate.onPaymentComplete(nil, error: integrationError)
                return
            }

            guard let configuration, (configuration.cardinalAuthenticationJWT != nil) else {
                let error = NSError(
                    domain: BTThreeDSecureFlowErrorDomain,
                    // TODO: - Create Error enum for 3DS module
                    code: BTThreeDSecureFlowErrorType.configuration.rawValue,
                    userInfo: [NSLocalizedDescriptionKey: "Merchant does not have the required Cardinal authentication JWT."]
                )
                delegate.onPaymentComplete(nil, error: error)
                return
            }

            self.prepareLookup(apiClient: apiClient) { error in
                if let error {
                    delegate.onPaymentComplete(nil, error: error)
                    return
                }

                self.startRequest(request: request, configuration: configuration)
            }
        }
    }

    public func handleOpen(_ url: URL) {
        guard let jsonAuthResponse = BTURLUtils.queryParameters(for: url)["auth_response"],
                jsonAuthResponse.count != 0 else {
            paymentFlowClientDelegate?.apiClient().sendAnalyticsEvent("ios.three-d-secure.missing-auth-response")
            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTThreeDSecureError.authenticationResponse("Auth Response missing from URL."))
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonAuthResponse) else {
            paymentFlowClientDelegate?.apiClient().sendAnalyticsEvent("ios.three-d-secure.invalid-auth-response")
            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTThreeDSecureError.authenticationResponse("Auth Response JSON parsing error."))
            return
        }

        let authBody = BTJSON(value: jsonData)
        let result = BTThreeDSecureResult(json: authBody)

        guard let apiClient = paymentFlowClientDelegate?.apiClient() else {
            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTThreeDSecureError.invalidAPIClient)
            return
        }

        if let errorMessage = result.errorMessage, result.tokenizedCard == nil {
            apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.failed")

            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTThreeDSecureError.authenticationResponse(errorMessage))
            return
        }

        logThreeDSecureCompletedAnalytics(forResult: result, apiClient: apiClient)
        paymentFlowClientDelegate?.onPaymentComplete(result, error: nil)
    }

    public func paymentFlowName() -> String {
        "three-d-secure"
    }
}

// MARK: - BTThreeDSecureRequestDelegate Protocol Conformance

extension BTThreeDSecureRequestSwift: BTThreeDSecureRequestDelegateSwift {

    public func onLookupComplete(
        _ request: BTThreeDSecureRequest,
        lookupResult result: BTThreeDSecureResult,
        next: (() -> Void)
    ) {
        next()
    }
}
