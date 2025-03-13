import XCTest
@testable import BraintreeAmericanExpress
@testable import BraintreeCard
@testable import BraintreeCore

class BraintreeAmexExpress_IntegrationTests: XCTestCase {
    
    func testGetRewardsBalance_returnsResult() async {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientTokenVersion3)!
        let cardClient = BTCardClient(authorization: BTIntegrationTestsConstants.sandboxClientTokenVersion3)
        let amexClient = BTAmericanExpressClient(authorization: BTIntegrationTestsConstants.sandboxClientTokenVersion3)
        
        let card = BTCard(
            number: "371260714673002",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "1234"
        )
        
        do {
            let tokenizedCard = try await cardClient.tokenize(card)
            let rewardsBalance = try await amexClient.getRewardsBalance(forNonce: tokenizedCard.nonce, currencyISOCode: "USD")
            
            XCTAssertEqual(rewardsBalance.rewardsAmount, "45256433")
            XCTAssertEqual(rewardsBalance.rewardsUnit, "Points")
            XCTAssertEqual(rewardsBalance.currencyAmount, "316795.03")
            XCTAssertEqual(rewardsBalance.currencyIsoCode, "USD")
        } catch {
            XCTFail("Unexpected error: \(error.localizedDescription)")
        }
    }
}
