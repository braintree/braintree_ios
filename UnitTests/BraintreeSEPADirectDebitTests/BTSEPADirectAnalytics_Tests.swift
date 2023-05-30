import XCTest
@testable import BraintreeSEPADirectDebit

final class BTSEPADirectAnalytics_Tests: XCTestCase {
    
    func test_tokenizeAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTSEPADirectAnalytics.tokenizeStarted, "sepa:tokenize:started")
        XCTAssertEqual(BTSEPADirectAnalytics.tokenizeSucceeded, "sepa:tokenize:succeeded")
        XCTAssertEqual(BTSEPADirectAnalytics.tokenizeFailed, "sepa:tokenize:failed")
        XCTAssertEqual(BTSEPADirectAnalytics.challengeCanceled, "sepa:tokenize:challenge:canceled")
        
        XCTAssertEqual(BTSEPADirectAnalytics.createMandateChallengeRequired, "sepa:tokenize:create-mandate:challenge-required")
        XCTAssertEqual(BTSEPADirectAnalytics.createMandateSucceeded, "sepa:tokenize:create-mandate:succeeded")
        XCTAssertEqual(BTSEPADirectAnalytics.createMandateFailed, "sepa:tokenize:create-mandate:failed")
        XCTAssertEqual(BTSEPADirectAnalytics.challengePresentationSucceeded, "sepa:tokenize:challenge-presentation:succeeded")
        XCTAssertEqual(BTSEPADirectAnalytics.challengePresentationFailed, "sepa:tokenize:challenge-presentation:failed")
        XCTAssertEqual(BTSEPADirectAnalytics.challengeFailed, "sepa:tokenize:challenge:failed")
        XCTAssertEqual(BTSEPADirectAnalytics.challengeSucceeded, "sepa:tokenize:challenge:succeeded")
    }
}
