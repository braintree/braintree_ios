import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

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
                paysheetDetails: Variables.InputParameters.PaysheetDetails(request: request)
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
                
                var collectCustomerBillingAddress: String?
                var collectCustomerShippingAddress: String?
                var transactionDetails: TransactionDetails?
                
                init(request: BTVenmoRequest) {
                    self.collectCustomerBillingAddress = "\(request.collectCustomerBillingAddress)"
                    self.collectCustomerShippingAddress = "\(request.collectCustomerShippingAddress)"
                    self.transactionDetails = Variables.InputParameters.PaysheetDetails.TransactionDetails(
                        subTotalAmount: request.subTotalAmount,
                        discountAmount: request.discountAmount,
                        taxAmount: request.taxAmount,
                        shippingAmount: request.shippingAmount,
                        totalAmount: request.totalAmount,
                        lineItems: request.lineItems?.compactMap {
                            Variables.InputParameters.PaysheetDetails.LineItem(item: $0)
                        }
                    )
                }
                
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
                    let type: String
                    let unitTaxAmount: String?
                    let description: String?
                    let productCode: String?
                    let url: String?
                    
                    init(item: BTVenmoLineItem) {
                        self.quantity = item.quantity
                        self.unitAmount = item.unitAmount
                        self.name = item.name
                        self.type = item.kind == .debit ? "DEBIT" : "CREDIT"
                        if let tax = item.unitTaxAmount, !tax.isEmpty {
                            self.unitTaxAmount = tax
                        } else {
                            self.unitTaxAmount = "0"
                        }
                        self.description = item.itemDescription
                        self.productCode = item.productCode
                        self.url = item.url?.absoluteString
                    }
                }
            }
        }
    }
}
