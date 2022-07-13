import XCTest
@testable import BraintreeSEPADirectDebit
@testable import BraintreeCore

class CreateMandateResult_Tests: XCTestCase {

    func testInitWithJSON() throws {
        let jsonString = """
        {
            "message": {
                "body": {
                    "sepaDebitAccount": {
                        "paypalV2OrderId": "3M4823521V931154L",
                        "approvalUrl": "https://api.test19.stage.paypal.com/directdebit/mandate/authorize?cart_id=3M4823521V931154L\\u0026auth_code=C21_A.AAfdeSkAgu3HOvz2APRL9II1frofQCtCCwnCWJuSTDxy46cC1X7C3DQwJjanPG9j578EIYVHpl12GLAptqwl7AMAQB6eQA",
                        "last4":"4020",
                        "merchantOrPartnerCustomerId":"FE08BE5DFE6445A08429",
                        "bankReferenceToken":"QkEtNE41NkpHTjgyQTlZQQ",
                        "mandateType":"ONE_OFF"
                    }
                },
                "success?":true
            }
        }
        """

        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let result = CreateMandateResult(json: json)

        XCTAssertEqual(result.bankReferenceToken, "QkEtNE41NkpHTjgyQTlZQQ")
        XCTAssertEqual(result.ibanLastFour, "4020")
        XCTAssertEqual(result.customerID, "FE08BE5DFE6445A08429")
        XCTAssertEqual(result.mandateType, "ONE_OFF")
        XCTAssertEqual(
            result.approvalURL,
            "https://api.test19.stage.paypal.com/directdebit/mandate/authorize?cart_id=3M4823521V931154L&auth_code=C21_A.AAfdeSkAgu3HOvz2APRL9II1frofQCtCCwnCWJuSTDxy46cC1X7C3DQwJjanPG9j578EIYVHpl12GLAptqwl7AMAQB6eQA"
        )
    }
}
