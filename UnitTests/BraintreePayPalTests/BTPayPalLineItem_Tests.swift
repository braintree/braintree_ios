import Foundation
import XCTest
@testable import BraintreePayPal

class BTPayPalLineItem_Tests: XCTestCase {
    
    func testRequestParameters() {
        let lineItem = BTPayPalLineItem(quantity: 1, unitAmount: "10", name: "item-name", kind: BTPayPalLineItemKind.debit);
        lineItem.unitTaxAmount = "10";
        lineItem.imageUrl = "http://example/image.jpg";
        lineItem.upcCode = "upc-code";
        lineItem.upcType = BTPayPalLineItemUpcType.UPC_A;

        let requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["name"] as! String, "item-name");
        XCTAssertEqual(requestParams["type"] as! String, "DEBIT");
        XCTAssertEqual(requestParams["unitAmount"] as! String, "10");
        XCTAssertEqual(requestParams["quantity"] as! Int, 1);
        XCTAssertEqual(requestParams["unitTaxAmount"] as! String, "10");
        XCTAssertEqual(requestParams["imageUrl" as! String, "http://example/image.jpg");
        XCTAssertEqual(requestParams["upcCode" as! String, "upc-code");
        XCTAssertEqual(requestParams["upcType" as! String, "UPC-A");
    }
}
