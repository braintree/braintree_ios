import Foundation
import BraintreeCore

// swiftlint:disable nesting
/// The POST body for graph QL `mutation CreateVenmoPaymentContext`
struct VenmoCreatePaymentContextGraphQLBody: BTGraphQLEncodableBody {
    
    var query: String
    var variables: Variables
    
    init(request: BTVenmoRequest, merchantProfileID: String?) {
        // swiftlint:disable:next line_length
        self.query = "mutation CreateVenmoPaymentContext($input: CreateVenmoPaymentContextInput!) { createVenmoPaymentContext(input: $input) { venmoPaymentContext { id } } }"
        self.variables = Variables(request: request, merchantProfileID: merchantProfileID)
    }
    
    
    struct Variables: Encodable {
        
        let input: InputParameters
        
        init(request: BTVenmoRequest, merchantProfileID: String?) {
            self.input = InputParameters(
                paymentMethodUsage: request.paymentMethodUsage.stringValue,
                merchantProfileID: merchantProfileID,
                customerClient: "MOBILE_APP",
                intent: "CONTINUE",
                isFinalAmount: request.isFinalAmount.description,
                displayName: request.displayName,
                paysheetDetails: Variables.InputParameters.PaysheetDetails(
                    collectCustomerBillingAddress: request.collectCustomerBillingAddress,
                    collectCustomerShippingAddress: request.collectCustomerShippingAddress,
                    transactionDetails: Variables.InputParameters.PaysheetDetails.TransactionDetails(
                        lineItems: request.lineItems?.map { item in
                            Variables.InputParameters.PaysheetDetails.LineItem(
                                quantity: item.quantity,
                                unitAmount: item.unitAmount,
                                name: item.name,
                                kind: item.kind.rawValue,
                                unitTaxAmount: item.unitTaxAmount ?? "0",
                                itemDescription: item.itemDescription,
                                productCode: item.productCode,
                                url: item.url
                            )
                        }
                    )
                )
            )
        }
        
        struct InputParameters: Encodable {
            
            var paymentMethodUsage: String?
            var merchantProfileID: String?
            var customerClient: String = "MOBILE_APP"
            var intent: String = "CONTINUE"
            var isFinalAmount: String?
            var displayName: String?
            var paysheetDetails: PaysheetDetails?
            
            enum CodingKeys: String, CodingKey {
                case paymentMethodUsage
                case merchantProfileID = "merchantProfileId"
                case customerClient
                case intent
                case isFinalAmount
                case displayName
                case paysheetDetails
            }
            
            struct PaysheetDetails: Encodable {
                
                var collectCustomerBillingAddress: Bool?
                var collectCustomerShippingAddress: Bool?
                var transactionDetails: TransactionDetails?
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    
                    try container.encodeIfPresent(collectCustomerBillingAddress, forKey: .collectCustomerBillingAddress)
                    try container.encodeIfPresent(collectCustomerShippingAddress, forKey: .collectCustomerShippingAddress)
                    
                    if let transactionDetails = transactionDetails {
                        let properties = [
                            transactionDetails.subTotalAmount,
                            transactionDetails.discountAmount,
                            transactionDetails.taxAmount,
                            transactionDetails.shippingAmount,
                            transactionDetails.totalAmount
                        ]
                        
                        if !properties.allSatisfy({ $0?.isEmpty ?? true }) || !(transactionDetails.lineItems?.isEmpty ?? true) {
                            try container.encode(transactionDetails, forKey: .transactionDetails)
                        }
                    }
                }
                
                enum CodingKeys: String, CodingKey {
                    case collectCustomerBillingAddress
                    case collectCustomerShippingAddress
                    case transactionDetails
                }
                
                struct TransactionDetails: Encodable {
                    
                    var subTotalAmount: String?
                    var discountAmount: String?
                    var taxAmount: String?
                    var shippingAmount: String?
                    var totalAmount: String?
                    let lineItems: [LineItem]?
                    
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.container(keyedBy: CodingKeys.self)
                        
                        try container.encodeIfPresent(subTotalAmount, forKey: .subTotalAmount)
                        try container.encodeIfPresent(discountAmount, forKey: .discountAmount)
                        try container.encodeIfPresent(taxAmount, forKey: .taxAmount)
                        try container.encodeIfPresent(shippingAmount, forKey: .shippingAmount)
                        try container.encodeIfPresent(totalAmount, forKey: .totalAmount)
                        if let lineItems, !lineItems.isEmpty {
                            try container.encode(lineItems, forKey: .lineItems)
                        }
                    }
                    
                    enum CodingKeys: String, CodingKey {
                        case subTotalAmount
                        case discountAmount
                        case taxAmount
                        case shippingAmount
                        case totalAmount
                        case lineItems
                    }
                }
                
                struct LineItem: Encodable {
                    
                    let quantity: Int
                    let unitAmount: String
                    let name: String
                    let kind: Int
                    let unitTaxAmount: String?
                    let itemDescription: String?
                    let productCode: String?
                    let url: URL?
                }
            }
        }
    }
}
