import XCTest
@testable import BraintreeThreeDSecure

final class BTThreeDSecureAnalytics_Tests: XCTestCase {
    
    func test_ThreeDSecureAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTThreeDSecureAnalytics.verifyStarted, "3ds:verify:started")
        XCTAssertEqual(BTThreeDSecureAnalytics.verifyFailed, "3ds:verify:failed")
        XCTAssertEqual(BTThreeDSecureAnalytics.challengeRequired, "3ds:verify:challenge-required")
        XCTAssertEqual(BTThreeDSecureAnalytics.challengeSucceeded, "3ds:verify:challenge.succeeded")
        XCTAssertEqual(BTThreeDSecureAnalytics.challengeFailed, "3ds:verify:challenge.failed")
        XCTAssertEqual(BTThreeDSecureAnalytics.jwtAuthSucceeded, "3ds:verify:authenticate-jwt:succeeded")
        
    }
}
