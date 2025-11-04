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
                paysheetDetails: InputParameters.PaysheetDetails(request: request)
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
                    let properties = [
                        request.subTotalAmount,
                        request.discountAmount,
                        request.taxAmount,
                        request.shippingAmount,
                        request.totalAmount
                    ]
                    
                    if !properties.allSatisfy({ $0?.isEmpty ?? true }) || !(request.lineItems?.isEmpty ?? true) {
                        self.transactionDetails = TransactionDetails(request: request)
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
                    var lineItems: [LineItem]?
                    
                    init(request: BTVenmoRequest) {
                        self.subTotalAmount = request.subTotalAmount
                        self.discountAmount = request.discountAmount
                        self.taxAmount = request.taxAmount
                        self.shippingAmount = request.shippingAmount
                        self.totalAmount = request.totalAmount
                        
                        if let lineItems = request.lineItems, !lineItems.isEmpty {
                            self.lineItems = lineItems.compactMap { LineItem(item: $0) }
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
                    let unitTaxAmount: String
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
