import Foundation

class BTThreeDSecureAnalytics {
    
    // MARK: Conversion Events
    
    static let verifyStarted = "3ds:verify:started"
    static let verifySucceeded = "3ds:verify:succeeded"
    static let verifyFailed = "3ds:verify:failed"
    
    // MARK: Others
    static let challengeRequired = "3ds:verify:challenge-required"
    static let challengeSucceeded = "3ds:verify:challenge.succeeded"
    static let challengeFailed = "3ds:verify:challenge.failed"
    static let jwtAuthSucceeded = "3ds:verify:authenticate-jwt:succeeded"
    
    static let lookupSucceeded = "3ds:verify:lookup:succeeded"
}
