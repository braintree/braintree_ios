import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for `/v1/payment_methods/paypal_accounts`
struct PayPalAccountPOSTEncodable: Encodable {

    let meta: Meta
    let payPalAccount: PayPalAccount
    let merchantAccountID: String?

    init(
        metadata: BTClientMetadata,
        request: BTPayPalRequest,
        client: BTAPIClient,
        paymentType: BTPayPalPaymentType,
        url: URL?,
        correlationID: String?
    ) {
        self.meta = Meta(
            sessionID: metadata.sessionID,
            integration: metadata.integration.stringValue,
            source: BTClientMetadataSource.payPalBrowser.stringValue
        )

        self.payPalAccount = PayPalAccount(
            request: request,
            client: client,
            paymentType: paymentType,
            url: url,
            correlationID: correlationID
        )

        self.merchantAccountID = request.merchantAccountID
    }

    init(
        metadata: BTClientMetadata,
        merchantAccountID: String?,
        baToken: String,
        correlationID: String?
    ) {
        self.meta = Meta(
            sessionID: metadata.sessionID,
            integration: metadata.integration.stringValue,
            source: BTClientMetadataSource.payPalBrowser.stringValue
        )
        self.payPalAccount = PayPalAccount(baToken: baToken, correlationID: correlationID)
        self.merchantAccountID = merchantAccountID
    }

    enum CodingKeys: String, CodingKey {
        case meta = "_meta"
        case payPalAccount = "paypal_account"
        case merchantAccountID = "merchant_account_id"
    }
}

struct Meta: Encodable {

    let sessionID: String
    let integration: String
    let source: String

    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case integration
        case source
    }
}

struct PayPalAccount: Encodable {

    let responseType: String
    let intent: String?
    let correlationID: String?
    let options: Options?
    let client: Client

    /// The web response returned by the PayPal browser flow.
    let response: PayPalResponse?

    /// The billing agreement token used to tokenize a pending PayPal app switch session.
    let billingAgreementToken: String?

    init(
        request: BTPayPalRequest,
        client: BTAPIClient,
        paymentType: BTPayPalPaymentType,
        url: URL?,
        correlationID: String?,
        responseType: String = "web"
    ) {
        self.responseType = responseType
        self.correlationID = correlationID
        options = paymentType == .checkout ? Options(validate: false) : nil
        intent  = paymentType == .checkout ? (request as? BTPayPalCheckoutRequest)?.intent.stringValue : nil
        self.client = Client()
        self.response = PayPalResponse(webURL: url?.absoluteString ?? "")
        self.billingAgreementToken = nil
    }

    /// Initializes a PayPal account payload for tokenizing a pending app switch billing agreement token.
    init(baToken: String, correlationID: String?) {
        self.responseType = "web"
        self.correlationID = correlationID
        self.options = nil
        self.intent = nil
        self.client = Client()
        self.response = nil
        self.billingAgreementToken = baToken
    }

    enum CodingKeys: String, CodingKey {
        case responseType = "response_type"
        case intent
        case correlationID = "correlation_id"
        case options
        case client
        case response
        case billingAgreementToken = "billing_agreement_token"
    }
}

struct Options: Encodable {

    let validate: Bool
}

struct Client: Encodable {

    let platform = "iOS"
    let productName = "PayPal"
    let paypalSdkVersion = "version"

    enum CodingKeys: String, CodingKey {
        case platform
        case productName = "product_name"
        case paypalSdkVersion = "paypal_sdk_version"
    }
}

struct PayPalResponse: Encodable {

    let webURL: String
}
