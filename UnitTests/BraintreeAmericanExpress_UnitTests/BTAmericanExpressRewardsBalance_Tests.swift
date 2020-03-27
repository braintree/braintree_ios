import XCTest

class BTAmericanExpressRewardsBalance_Tests: XCTestCase {
    
    func testInitWithJson_parsesSuccessJsonCorrectly() {
        let jsonString =
            """
            {
                "conversionRate": "0.0070",
                "currencyAmount": "316795.03",
                "currencyIsoCode": "USD",
                "requestId": "715f4712-8690-49ed-8cc5-d7fb1c2d",
                "rewardsUnit": "Points",
                "rewardsAmount": "45256433"
            }
            """
        
        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let rewardsBalance = BTAmericanExpressRewardsBalance(json: json)
        XCTAssertEqual(rewardsBalance.conversionRate, "0.0070")
        XCTAssertEqual(rewardsBalance.currencyAmount, "316795.03")
        XCTAssertEqual(rewardsBalance.currencyIsoCode, "USD")
        XCTAssertEqual(rewardsBalance.requestId, "715f4712-8690-49ed-8cc5-d7fb1c2d")
        XCTAssertEqual(rewardsBalance.rewardsAmount, "45256433")
        XCTAssertEqual(rewardsBalance.rewardsUnit, "Points")
        XCTAssertNil(rewardsBalance.errorCode)
        XCTAssertNil(rewardsBalance.errorMessage)

    }
    
    func testInitWithJson_parsesErrorJsonCorrectly() {
        let jsonString =
            """
            {
              "error": {
                "code": "abv6178",
                "message": "Rewards balance error message"
              }
            }
            """
        
        let json = BTJSON(data: jsonString.data(using: String.Encoding.utf8)!)
        let rewardsBalance = BTAmericanExpressRewardsBalance(json: json)
        XCTAssertEqual(rewardsBalance.errorCode, "abv6178")
        XCTAssertEqual(rewardsBalance.errorMessage, "Rewards balance error message")
        XCTAssertNil(rewardsBalance.conversionRate)
        XCTAssertNil(rewardsBalance.currencyAmount)
        XCTAssertNil(rewardsBalance.currencyIsoCode)
        XCTAssertNil(rewardsBalance.requestId)
        XCTAssertNil(rewardsBalance.rewardsAmount)
        XCTAssertNil(rewardsBalance.rewardsUnit)
    }
}
