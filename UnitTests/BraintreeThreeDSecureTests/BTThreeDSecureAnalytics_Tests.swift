import XCTest
@testable import BraintreeThreeDSecure

final class BTThreeDSecureAnalytics_Tests: XCTestCase {
    
    func test_ThreeDSecureAnalyticsEvents_sendsExpectedEventNames() {
        XCTAssertEqual(BTThreeDSecureAnalytics.verifyStarted, "3ds:verify:started")
        XCTAssertEqual(BTThreeDSecureAnalytics.verifySucceeded, "3ds:verify:succeeded")
        XCTAssertEqual(BTThreeDSecureAnalytics.verifyFailed, "3ds:verify:failed")
        XCTAssertEqual(BTThreeDSecureAnalytics.verifyCanceled, "3ds:verify:canceled")
        
        XCTAssertEqual(BTThreeDSecureAnalytics.challengeRequired, "3ds:verify:lookup:challenge-required")
        XCTAssertEqual(BTThreeDSecureAnalytics.lookupSucceeded, "3ds:verify:lookup:succeeded")
        XCTAssertEqual(BTThreeDSecureAnalytics.lookupFailed, "3ds:verify:lookup:failed")
                
        XCTAssertEqual(BTThreeDSecureAnalytics.challengeSucceeded, "3ds:verify:challenge.succeeded")
        XCTAssertEqual(BTThreeDSecureAnalytics.challengeFailed, "3ds:verify:challenge.failed")
        
        XCTAssertEqual(BTThreeDSecureAnalytics.jwtAuthSucceeded, "3ds:verify:authenticate-jwt:succeeded")
        XCTAssertEqual(BTThreeDSecureAnalytics.jwtAuthFailed, "3ds:verify:authenticate-jwt:failed")        
    }
}
