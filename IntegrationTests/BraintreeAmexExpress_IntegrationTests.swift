import Foundation
import XCTest
@testable import BraintreeCore
@testable import BraintreeAmericanExpress
@testable import BraintreeCard

class BTAmericanExpressClient_IntegrationTests: XCTestCase {
    
    // MARK: - Properties
    
    var americanExpressClient: BTAmericanExpressClient!
    var cardClient: BTCardClient!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        americanExpressClient = BTAmericanExpressClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
        cardClient = BTCardClient(authorization: BTIntegrationTestsConstants.sandboxClientToken)
    }
    
    // MARK: - getRewardsBalance
    
    func testGetRewardsBalance_returnsResult() async {
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
    
    func testGetRewardsBalance_withNonAmexNonce_returnsError() {
        let cardExpectation = expectation(description: "Tokenize Visa card")
        var visaNonce: String?
        
        let card = BTCard(
            number: "4111111111111111",
            expirationMonth: "12",
            expirationYear: Helpers.shared.futureYear(),
            cvv: "123"
        )
        
        cardClient.tokenize(card) { tokenizedCard, error in
            guard let tokenizedCard else {
                XCTFail("Expected a nonce to be returned")
                return
            }
            
            visaNonce = tokenizedCard.nonce
            cardExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        guard let nonce = visaNonce else {
            XCTFail("Visa nonce was not set")
            return
        }
        
        let rewardsExpectation = expectation(description: "Get rewards balance for non-Amex nonce returns error")
        
        americanExpressClient.getRewardsBalance(forNonce: nonce, currencyISOCode: "USD") { rewardsBalance, error in
            guard let error = error as? NSError else {
                XCTFail("Expected an error to be returned")
                return
            }
            
            XCTAssertNil(rewardsBalance)
            XCTAssertNotNil(error)
            rewardsExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testGetRewardsBalance_usingTokenizationKey_returnsError() {
        americanExpressClient = BTAmericanExpressClient(authorization: BTIntegrationTestsConstants.sandboxTokenizationKey)
        
        let expectation = expectation(description: "Get rewards balance using tokenization key")
        
        americanExpressClient.getRewardsBalance(forNonce: "fake-nonce", currencyISOCode: "USD") { rewardsBalance, error in
            guard let error = error as? NSError else {
                XCTFail("Expected an error to be returned")
                return
            }
            
            XCTAssertNil(rewardsBalance)
            XCTAssertEqual(error.domain, BTCoreConstants.httpErrorDomain)
            XCTAssertEqual(error.code, 2)
            
            let httpResponse = error.userInfo[BTCoreConstants.urlResponseKey] as! HTTPURLResponse
            XCTAssertEqual(httpResponse.statusCode, 403)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
}
