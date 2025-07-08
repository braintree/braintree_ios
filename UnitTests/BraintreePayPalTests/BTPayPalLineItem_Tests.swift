import Foundation
import XCTest
@testable import BraintreePayPal

class BTPayPalLineItem_Tests: XCTestCase {
    
    func testUPCTypeStringReturnsCorrectValue() {
        var lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit)

        lineItem.upcType = .UPC_A 
        var requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["upc_type"], "UPC-A")

        lineItem.upcType = .UPC_B 
        requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["upc_type"], "UPC-B")

        lineItem.upcType = .UPC_C 
        requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["upc_type"], "UPC-C")

        lineItem.upcType = .UPC_D 
        requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["upc_type"], "UPC-D")

        lineItem.upcType = .UPC_E 
        requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["upc_type"], "UPC-E")

        lineItem.upcType = .UPC_2 
        requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["upc_type"]!, "UPC-2")

        lineItem.upcType = .UPC_5
        requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["upc_type"], "UPC-5")
    }

    func testKindStringReturnsCorrectValue() {
        var lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit)
        var requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["kind"], "debit")

        lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .credit)
        requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["kind"], "credit")
    }
    
    func testRequestParameters() {
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: BTPayPalLineItemKind.debit)
        lineItem.unitTaxAmount = "8"
        lineItem.itemDescription = "item description"
        lineItem.imageURL = URL(string: "https://example.com/image.jpg")
        lineItem.url = URL(string: "https://example.com")
        lineItem.productCode = "product-code"
        lineItem.upcCode = "upc-code"
        let requestParams = lineItem.requestParameters()
        XCTAssertEqual(requestParams["name"], "item-name")
        XCTAssertEqual(requestParams["kind"], "debit")
        XCTAssertEqual(requestParams["unit_amount"], "10")
        XCTAssertEqual(requestParams["quantity"], "1")
        XCTAssertEqual(requestParams["unit_tax_amount"], "8")
        XCTAssertEqual(requestParams["description"], "item description")
        XCTAssertEqual(requestParams["image_url"], "https://example.com/image.jpg")
        XCTAssertEqual(requestParams["url"], "https://example.com")
        XCTAssertEqual(requestParams["product_code"], "product-code")
        XCTAssertEqual(requestParams["upc_code"], "upc-code")
    }
}
