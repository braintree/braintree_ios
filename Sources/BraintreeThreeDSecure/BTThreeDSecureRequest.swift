import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePaymentFlow)
import BraintreePaymentFlow
#endif

/// Used to initialize a 3D Secure payment flow
public class BTThreeDSecureRequest: BTPaymentFlowRequest {
    
    // MARK: - Public Properties

    /// A nonce to be verified by ThreeDSecure
    @objc public var nonce: String

    /// The amount for the transaction
    @objc public var amount: Double

    /// Optional. The account type selected by the cardholder
    /// - Note: Some cards can be processed using either a credit or debit account and cardholders have the option to choose which account to use.
    @objc public var accountType: BTThreeDSecureAccountType

    /// Optional. The billing address used for verification
    @objc public var billingAddress: BTThreeDSecurePostalAddress?

    /// Optional. The mobile phone number used for verification
    /// - Note: Only numbers. Remove dashes, parentheses and other characters
    @objc public var mobilePhoneNumber: String?

    /// Optional. The email used for verification
    @objc public var email: String?

    /// Optional. The shipping method chosen for the transaction
    @objc public var shippingMethod: BTThreeDSecureShippingMethod

    /// Optional. The additional information used for verification
    @objc public var additionalInformation: BTThreeDSecureAdditionalInformation?

    /// Optional. If set to true, an authentication challenge will be forced if possible.
    @objc public var challengeRequested: Bool

    /// Optional. If set to true, an exemption to the authentication challenge will be requested.
    @objc public var exemptionRequested: Bool

    /// Optional. The exemption type to be requested. If an exemption is requested and the exemption's conditions are satisfied, then it will be applied.
    @objc public var requestedExemptionType: BTThreeDSecureRequestedExemptionType

    /// :nodoc:
    // TODO: do we need a doc string for this?
    @objc public var dataOnlyRequested: Bool

    /// Optional. An authentication created using this property should only be used for adding a payment method to the merchant's vault and not for creating transactions.
    ///
    /// Defaults to `.unspecified.`
    ///
    /// If set to `.challengeRequested`, the authentication challenge will be requested from the issuer to confirm adding new card to the merchant's vault.
    /// If set to `.notRequested` the authentication challenge will not be requested from the issuer.
    /// If set to `.unspecified`, when the amount is 0, the authentication challenge will be requested from the issuer.
    /// If set to `.unspecified`, when the amount is greater than 0, the authentication challenge will not be requested from the issuer.
    @objc public var cardAddChallenge: BTThreeDSecureCardAddChallenge

    /// Optional. UI Customization for 3DS2 challenge views.
    @objc public var v2UICustomization: BTThreeDSecureV2UICustomization?

    /// A delegate for receiving information about the ThreeDSecure payment flow.
    @objc public weak var threeDSecureRequestDelegate: BTThreeDSecureRequestDelegate?
    
    // MARK: - Internal Properties

    /// Set the BTPaymentFlowClientDelegate for handling the client events.
    // TODO: can be internal when BTPaymentFlowClient+ThreeDSecure
    @objc public weak var paymentFlowClientDelegate: BTPaymentFlowClientDelegate?

    /// The dfReferenceID for the session. Exposed for testing.
    // TODO: can be internal when BTPaymentFlowClient+ThreeDSecure
    @objc public var dfReferenceID: String = ""

    var threeDSecureV2Provider: BTThreeDSecureV2Provider?

    // TODO: Can be moved into the enum once BTPaymentFlowClient+ThreeDSecure is in Swift
    @objc public var accountTypeAsString: String? {
        switch accountType {
        case .credit:
            return "credit"
        case .debit:
            return "debit"
        case .unspecified:
            return nil
        }
    }

    // TODO: Can be moved into the enum once BTPaymentFlowClient+ThreeDSecure is in Swift
    @objc public var requestedExemptionTypeAsString: String? {
        switch requestedExemptionType {
        case .lowValue:
            return "low_value"
        case .secureCorporate:
            return "secure_corporate"
        case .trustedBeneficiary:
            return "trusted_beneficiary"
        case .transactionRiskAnalysis:
            return "transaction_risk_analysis"
        case .unspecified:
            return nil
        }
    }

    // TODO: Can be moved into the enum once BTPaymentFlowClient+ThreeDSecure is in Swift
    @objc public var shippingMethodAsString: String? {
        switch shippingMethod {
        case .sameDay:
            return "01"
        case .expedited:
            return "02"
        case .priority:
            return "03"
        case .ground:
            return "04"
        case .electronicDelivery:
            return "05"
        case .shipToStore:
            return "06"
        case .unspecified:
            return nil
        }
    }
    
    // MARK: - Initializer
    
    @objc public convenience init(nonce: String, amount: Double) {
        self.init(nonce: nonce, amount: amount)
    }
    
    required public init(
        nonce: String,
        amount: Double,
        accountType: BTThreeDSecureAccountType,
        billingAddress: BTThreeDSecurePostalAddress? = nil,
        mobilePhoneNumber: String? = nil,
        email: String? = nil,
        shippingMethod: BTThreeDSecureShippingMethod = .unspecified,
        additionalInformation: BTThreeDSecureAdditionalInformation? = nil,
        challengeRequested: Bool = false,
        exemptionRequested: Bool = false,
        requestedExemptionType: BTThreeDSecureRequestedExemptionType = .unspecified,
        dataOnlyRequested: Bool = false,
        cardAddChallenge: BTThreeDSecureCardAddChallenge = .unspecified,
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
    
    /// Prepare for a 3DS 2.0 flow.
    /// - Parameters:
    ///   - apiClient: The API client.
    ///   - completion: This completion will be invoked exactly once. If the error is nil then the preparation was successful.
    // TODO: can be internal and non obj-c when BTPaymentFlowClient+ThreeDSecure is in Swift
    @objc(prepareLookup:completion:)
    public func prepareLookup(
        apiClient: BTAPIClient,
        completion: @escaping (Error?) -> Void
    ) {
        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else { return }

            guard let configuration, error == nil else {
                completion(error)
                return
            }

            if configuration.cardinalAuthenticationJWT != nil {
                self.threeDSecureV2Provider = BTThreeDSecureV2Provider(
                    configuration: configuration,
                    apiClient: apiClient,
                    request: self
                ) { lookupParameters in
                    if let dfReferenceID = lookupParameters?["dfReferenceId"] {
                        self.dfReferenceID = dfReferenceID
                        completion(nil)
                    }
                }
            } else {
                completion(BTThreeDSecureError.configuration("Merchant is not configured for 3SD 2."))
                return
            }
        }
    }

    // TODO: Can be internal once BTPaymentFlowClient+ThreeDSecure is in Swift
    @objc(processLookupResult:configuration:)
    public func process(lookupResult: BTThreeDSecureResult, configuration: BTConfiguration) {
        if lookupResult.lookup?.requiresUserAuthentication == false {
            paymentFlowClientDelegate?.onPaymentComplete(lookupResult, error: nil)
            return
        }

        if lookupResult.lookup?.isThreeDSecureVersion2 == true {
            performV2Authentication(with: lookupResult)
        }
    }
    
    // MARK: - Private Methods
    
    private func start(request: BTPaymentFlowRequest, configuration: BTConfiguration) {
        guard let apiClient = paymentFlowClientDelegate?.apiClient() else {
            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTThreeDSecureError.invalidAPIClient)
            return
        }

        guard let threeDSecureRequest = request as? BTThreeDSecureRequest else {
            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTThreeDSecureError.cannotCastRequest)
            return
        }

        let paymentFlowClient = BTPaymentFlowClient(apiClient: apiClient)

        if threeDSecureRequest.threeDSecureRequestDelegate == nil {
            threeDSecureRequest.threeDSecureRequestDelegate = self
        }

        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.started")
        paymentFlowClient.performThreeDSecureLookup(threeDSecureRequest) { lookupResult, error in
            DispatchQueue.main.async {
                guard let lookupResult, error == nil else {
                    self.paymentFlowClientDelegate?.onPayment(with: nil, error: error)
                    return
                }

                let threeDSecureVersion = lookupResult.lookup?.threeDSecureVersion ?? "2"
                apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.3ds-version\(threeDSecureVersion)")

                self.threeDSecureRequestDelegate?.onLookupComplete(threeDSecureRequest, lookupResult: lookupResult) {
                    let requiresUserAuthentication = lookupResult.lookup?.requiresUserAuthentication ?? false
                    apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.challenge-presented\(self.stringFor(requiresUserAuthentication))")
                    self.process(lookupResult: lookupResult, configuration: configuration)
                }
            }
        }
    }
    
    private func performV2Authentication(with lookupResult: BTThreeDSecureResult) {
        guard let apiClient = paymentFlowClientDelegate?.apiClient() else {
            paymentFlowClientDelegate?.onPaymentComplete(nil, error: BTThreeDSecureError.invalidAPIClient)
            return
        }

        threeDSecureV2Provider?.process(lookupResult: lookupResult) { result, error in
            guard let result else {
                apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.failed")
                self.paymentFlowClientDelegate?.onPaymentComplete(nil, error: error)
                return
            }

            self.logThreeDSecureCompletedAnalytics(forResult: lookupResult, apiClient: apiClient)
            self.paymentFlowClientDelegate?.onPaymentComplete(result, error: error)
        }
    }
    
    private func logThreeDSecureCompletedAnalytics(forResult result: BTThreeDSecureResult, apiClient: BTAPIClient) {
        let liabilityShiftPossible = result.tokenizedCard?.threeDSecureInfo.liabilityShiftPossible ?? false
        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.liability-shift-possible.\(stringFor(liabilityShiftPossible))")

        let liabilityShifted = result.tokenizedCard?.threeDSecureInfo.liabilityShiftPossible ?? false
        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.liability-shifted.\(liabilityShifted)")

        apiClient.sendAnalyticsEvent("ios.three-d-secure.verification-flow.completed")
    }
    
    func stringFor(_ boolean: Bool) -> String {
        boolean ? "true" : "false"
    }
}

// MARK: - BTPaymentFlowRequestDelegate Protocol Conformance

extension BTThreeDSecureRequest: BTPaymentFlowRequestDelegate {

    public func handle(
        _ request: BTPaymentFlowRequest,
        client apiClient: BTAPIClient,
        paymentClientDelegate delegate: BTPaymentFlowClientDelegate
    ) {
        paymentFlowClientDelegate = delegate

        apiClient.sendAnalyticsEvent("ios.three-d-secure.initialized")

        apiClient.fetchOrReturnRemoteConfiguration { [weak self] configuration, error in
            guard let self else { return }

            if let error {
                self.paymentFlowClientDelegate?.onPaymentComplete(nil, error: error)
                return
            }

            var integrationError: Error?

            if configuration?.cardinalAuthenticationJWT == nil {
                NSLog("%@ BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly.", BTLogLevelDescription.string(for: .critical)  ?? "[BraintreeSDK] CRITICAL")
                integrationError = BTThreeDSecureError.configuration("BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly.")
            }

            if self.amount.isNaN {
                NSLog("%@ BTThreeDSecureRequest amount can not be NaN.", BTLogLevelDescription.string(for: .critical)  ?? "[BraintreeSDK] CRITICAL")
                integrationError = BTThreeDSecureError.configuration("BTThreeDSecureRequest amount can not be NaN.")
            }

            if let integrationError {
                delegate.onPaymentComplete(nil, error: integrationError)
                return
            }

            guard let configuration, configuration.cardinalAuthenticationJWT != nil else {
                delegate.onPaymentComplete(nil, error: BTThreeDSecureError.configuration("Merchant does not have the required Cardinal authentication JWT."))
                return
            }

            self.prepareLookup(apiClient: apiClient) { error in
                if let error {
                    delegate.onPaymentComplete(nil, error: error)
                    return
                }

                self.start(request: request, configuration: configuration)
            }
        }
    }

    public func handleOpen(_ url: URL) {
        guard let jsonAuthResponse = BTURLUtils.queryParameters(for: url)["auth_response"],
                jsonAuthResponse.count != 0 else {
            paymentFlowClientDelegate?.apiClient().sendAnalyticsEvent("ios.three-d-secure.missing-auth-response")

            let error = BTThreeDSecureError.authenticationResponse("Auth Response missing from URL.")
            paymentFlowClientDelegate?.onPaymentComplete(nil, error: error)
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonAuthResponse) else {
            paymentFlowClientDelegate?.apiClient().sendAnalyticsEvent("ios.three-d-secure.invalid-auth-response")

            let error = BTThreeDSecureError.authenticationResponse("Auth Response JSON parsing error.")
            paymentFlowClientDelegate?.onPaymentComplete(nil, error: error)
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

extension BTThreeDSecureRequest: BTThreeDSecureRequestDelegate {

    public func onLookupComplete(
        _ request: BTThreeDSecureRequest,
        lookupResult result: BTThreeDSecureResult,
        next: (() -> Void)
    ) {
        next()
    }
}
