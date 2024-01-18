import Foundation
import XCTest
@testable import BraintreePayPal

class BTPayPalLineItem_Tests: XCTestCase {
    
    func testUPCTypeStringReturnsCorrectValue() {
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit)
       
        lineItem.upcType = .UPC_A 
        let requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["upc_type"] as! String, "UPC-A");
       
        lineItem.upcType = .UPC_B 
        requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["upc_type"] as! String, "UPC-B");
       
        lineItem.upcType = .UPC_C 
        requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["upc_type"] as! String, "UPC-C");
       
        lineItem.upcType = .UPC_D 
        requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["upc_type"] as! String, "UPC-D");
       
        lineItem.upcType = .UPC_E 
        requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["upc_type"] as! String, "UPC-E");
       
        lineItem.upcType = .UPC_1 
        requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["upc_type"] as! String, "UPC-1");
       
        lineItem.upcType = .UPC_2 
        requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["upc_type"] as! String, "UPC-2");
    }

    func testKindStringReturnsCorrectValue() {
        let lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .debit)
        let requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["kind"] as! String, "debit");
        
        lineItem = BTPayPalLineItem(quantity: "1", unitAmount: "10", name: "item-name", kind: .credit)
        requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["kind"] as! String, "credit");
    }
}
