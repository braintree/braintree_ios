import Foundation
import XCTest
@testable import BraintreePayPal

class BTPayPalLineItem_Tests: XCTestCase {
    
    func testUPCTypeStringReturnsCorrectValue() {
        
        var lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit, upcType: .UPC_A)
        var requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-A")

        lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit, upcType: .UPC_B)
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-B")

        lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit, upcType: .UPC_C)
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-C")

        lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit, upcType: .UPC_D)
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-D")

        lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit, upcType: .UPC_E)
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-E")

        lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit, upcType: .UPC_2)
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-2")

        lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit, upcType: .UPC_5)
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-5")
    }

    func testKindStringReturnsCorrectValue() {
        var lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit)
        var requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["kind"] as? String, "debit")
        
        lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .credit)
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["kind"] as? String, "credit")
    }
    
    func testRequestParameters() {
        let lineItem = BTPayPalLineItem(
            quantity: "1",
            unitAmount: "10",
            name: "item-name",
            kind: BTPayPalLineItemKind.debit,
            unitTaxAmount: "8",
            itemDescription: "item description",
            url: URL(string: "https://example.com"),
            productCode: "product-code",
            imageURL: URL(string: "https://example.com/image.jpg"),
            upcCode: "upc-code",
            upcType: .none
        )
        let requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["name"] as? String, "item-name")
        XCTAssertEqual(requestParams?["kind"] as? String, "debit")
        XCTAssertEqual(requestParams?["unit_amount"] as? String, "10")
        XCTAssertEqual(requestParams?["quantity"] as? String, "1")
        XCTAssertEqual(requestParams?["unit_tax_amount"] as? String, "8")
        XCTAssertEqual(requestParams?["description"] as? String, "item description")
        XCTAssertEqual(requestParams?["image_url"] as? String, "https://example.com/image.jpg")
        XCTAssertEqual(requestParams?["url"] as? String, "https://example.com")
        XCTAssertEqual(requestParams?["product_code"] as? String, "product-code")
        XCTAssertEqual(requestParams?["upc_code"] as? String, "upc-code")
    }
}
