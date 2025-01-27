import Foundation
import XCTest
@testable import BraintreePayPal

class BTPayPalLineItem_Tests: XCTestCase {
    
    func testUPCTypeStringReturnsCorrectValue() {
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit)

        lineItem.upcType = .UPC_A
        var requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-A")

        lineItem.upcType = .UPC_B 
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-B")

        lineItem.upcType = .UPC_C 
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-C")

        lineItem.upcType = .UPC_D 
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-D")

        lineItem.upcType = .UPC_E 
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-E")

        lineItem.upcType = .UPC_2 
        requestParams = try? lineItem.toDictionary()
        XCTAssertEqual(requestParams?["upc_type"] as? String, "UPC-2")

        lineItem.upcType = .UPC_5
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
}
