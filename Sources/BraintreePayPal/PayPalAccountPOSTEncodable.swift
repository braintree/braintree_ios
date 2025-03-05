import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for `/v1/payment_methods/paypal_accounts`
struct PayPalAccountPOSTEncodable: Encodable {

    let meta: Meta
    let paypalAccount: PayPalAccount
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
        
        self.paypalAccount = PayPalAccount(
            request: request,
            client: client,
            paymentType: paymentType,
            url: url,
            correlationID: correlationID
        )

        self.merchantAccountID = request.merchantAccountID
    }

    enum CodingKeys: String, CodingKey {
        case meta = "_meta"
        case paypalAccount = "paypal_account"
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
    let response: PayPalResponse

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
    }

    enum CodingKeys: String, CodingKey {
        case responseType = "response_type"
        case intent
        case correlationID = "correlation_id"
        case options
        case client
        case response
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
