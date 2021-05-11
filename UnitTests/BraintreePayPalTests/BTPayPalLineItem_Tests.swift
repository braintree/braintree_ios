import XCTest
import BraintreePayPal

class BTPayPalLineItem_Tests: XCTestCase {

    func testRequestParameters_setsAllValues() {
        let lineItem = BTPayPalLineItem(quantity: "2", unitAmount: "1.00", name: "some-item", kind: .credit)
        lineItem.unitTaxAmount = "0.20"
        lineItem.itemDescription = "some-description"
        lineItem.productCode = "123"
        lineItem.url = URL(string: "http://www.example.com")

        let requestParameters = lineItem.requestParameters()
        XCTAssertEqual(requestParameters["quantity"] as? String, "2")
        XCTAssertEqual(requestParameters["unit_amount"] as? String, "1.00")
        XCTAssertEqual(requestParameters["name"] as? String, "some-item")
        XCTAssertEqual(requestParameters["kind"] as? String, "credit")
        XCTAssertEqual(requestParameters["unit_tax_amount"] as? String, "0.20")
        XCTAssertEqual(requestParameters["description"] as? String, "some-description")
        XCTAssertEqual(requestParameters["product_code"] as? String, "123")
        XCTAssertEqual(requestParameters["url"] as? String, "http://www.example.com")
    }
}
