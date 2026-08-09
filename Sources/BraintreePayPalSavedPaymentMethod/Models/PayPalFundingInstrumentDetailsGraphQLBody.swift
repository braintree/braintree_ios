import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for the GraphQL query `PaypalFundingInstrumentDetails`
struct PayPalFundingInstrumentDetailsGraphQLBody: BTGraphQLEncodableBody {

    let query: String
    let variables: Variables

    init(
        fundingInstrumentType: BTPayPalFundingInstrumentFetchType,
        paymentMethodIDJWT: String?,
        orderID: String?,
        merchantAccountID: String?
    ) {
        query = """
            query PaypalFundingInstrumentDetails($input: PayPalFundingInstrumentDetailsInput!) {
                paypalFundingInstrumentDetails(input: $input) {
                    payer {
                        email
                        editable
                    }
                    paymentMethods {
                        label
                        imageUrl
                        lastDigits
                        type
                        subtype
                    }
                }
            }
            """
        variables = Variables(
            input: PayPalFundingInstrumentDetailsInput(
                fundingInstrumentType: fundingInstrumentType.rawValue,
                paymentMethodIDJWT: paymentMethodIDJWT,
                orderID: orderID,
                merchantAccountID: merchantAccountID
            )
        )
    }

    struct Variables: Encodable {

        let input: PayPalFundingInstrumentDetailsInput
    }
}

/// The `PayPalFundingInstrumentDetailsInput` GraphQL input type.
struct PayPalFundingInstrumentDetailsInput: Encodable {

    let fundingInstrumentType: String
    let integrationChannel = "BT_NATIVE_SDK"
    let paymentMethodIDJWT: String?
    let orderID: String?
    let merchantAccountID: String?

    enum CodingKeys: String, CodingKey {
        case fundingInstrumentType
        case integrationChannel
        case paymentMethodIDJWT = "paymentMethodIdJwt"
        case orderID = "orderId"
        case merchantAccountID = "merchantAccountId"
    }
}
