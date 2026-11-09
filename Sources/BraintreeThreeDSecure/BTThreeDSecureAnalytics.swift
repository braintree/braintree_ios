import Foundation

enum BTThreeDSecureAnalytics {
    
    // MARK: Conversion Events
    
    static let verifyStarted = "3ds:verify:started"
    static let verifySucceeded = "3ds:verify:succeeded"
    static let verifyFailed = "3ds:verify:failed"
    
    // cardinal sdk returns a cancelation result
    static let verifyCanceled = "3ds:verify:canceled"
    
    // MARK: Lookup Events
    
    static let lookupSucceeded = "3ds:verify:lookup:succeeded"
    static let lookupFailed = "3ds:verify:lookup:failed"
    static let challengeRequired = "3ds:verify:lookup:challenge-required"
    
    // MARK: Challenge Events
    
    static let challengeSucceeded = "3ds:verify:challenge.succeeded"
    static let challengeFailed = "3ds:verify:challenge.failed"
    
    // MARK: JWT Events
    
    static let jwtAuthSucceeded = "3ds:verify:authenticate-jwt:succeeded"
    static let jwtAuthFailed = "3ds:verify:authenticate-jwt:failed"
}
