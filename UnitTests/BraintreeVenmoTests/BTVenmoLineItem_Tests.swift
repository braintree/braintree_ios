import Foundation
import XCTest
@testable import BraintreeVenmo

class BTVenmoLineItem_Tests: XCTestCase {
    
    func testRequestParameters() {
        let lineItem = BTVenmoLineItem(quantity: 1, unitAmount: "10", name: "item-name", kind: BTVenmoLineItemKind.debit);
        lineItem.unitTaxAmount = "10";
        let requestParams = lineItem.requestParameters();
        XCTAssertEqual(requestParams["name"] as! String, "item-name");
        XCTAssertEqual(requestParams["type"] as! String, "DEBIT");
        XCTAssertEqual(requestParams["unitAmount"] as! String, "10");
        XCTAssertEqual(requestParams["quantity"] as! Int, 1);
        XCTAssertEqual(requestParams["unitTaxAmount"] as! String, "10");
    }
}
