import XCTest
@testable import BraintreeAmericanExpress
@testable import BraintreeCard
@testable import BraintreeCore

class BraintreeAmexExpress_IntegrationTests: XCTestCase {
    
    func testGetRewardsBalance_returnsResult() async {
        let apiClient = BTAPIClient(authorization: BTIntegrationTestsConstants.sandboxClientTokenVersion3)!
        let cardClient = BTCardClient(apiClient: apiClient)
        let amexClient = BTAmericanExpressClient(apiClient: apiClient)
        
        let card = BTCard()
        card.number = "371260714673002"
        card.expirationMonth = "12"
        card.expirationYear = Helpers.shared.futureYear()
        card.cvv = "1234"
        
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
