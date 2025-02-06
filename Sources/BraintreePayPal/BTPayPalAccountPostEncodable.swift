import Foundation

struct PayPalRequestBody: Encodable {
    let paypalAccount: PayPalAccount
    let meta: Meta

    enum CodingKeys: String, CodingKey {
        case paypalAccount = "paypal_account"
        case meta = "_meta"
    }
}

struct PayPalAccount: Encodable {
    let responseType: String
    let intent: String
    let correlationId: String
    let options: Options
    let client: Client
    let response: PayPalResponse

    enum CodingKeys: String, CodingKey {
        case responseType = "response_type"
        case intent
        case correlationId = "correlation_id"
        case options
        case client
        case response
    }
}

struct Options: Encodable {
    let validate: Bool
}

struct Client: Encodable {
    let platform: String
    let productName: String
    let paypalSdkVersion: String

    enum CodingKeys: String, CodingKey {
        case platform
        case productName = "product_name"
        case paypalSdkVersion = "paypal_sdk_version"
    }
}

struct PayPalResponse: Encodable {
    let webURL: String

    enum CodingKeys: String, CodingKey {
        case webURL
    }
}

struct Meta: Encodable {
    let integration: String
    let source: String
    let sessionId: String
}
