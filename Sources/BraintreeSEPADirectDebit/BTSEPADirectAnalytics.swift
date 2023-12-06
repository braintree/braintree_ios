import Foundation

enum BTSEPADirectAnalytics {
    
    // MARK: - Conversion Events
    
    static let tokenizeStarted = "sepa:tokenize:started"
    static let tokenizeSucceeded = "sepa:tokenize:succeeded"
    static let tokenizeFailed = "sepa:tokenize:failed"
    static let challengeCanceled = "sepa:tokenize:challenge:canceled"
    
    // MARK: - Additional Detail Events
    
    static let createMandateChallengeRequired = "sepa:tokenize:create-mandate:challenge-required"
    static let createMandateSucceeded = "sepa:tokenize:create-mandate:succeeded"
    static let createMandateFailed = "sepa:tokenize:create-mandate:failed"
    static let challengePresentationSucceeded = "sepa:tokenize:challenge-presentation:succeeded"
    static let challengePresentationFailed = "sepa:tokenize:challenge-presentation:failed"
    static let challengeSucceeded = "sepa:tokenize:challenge:succeeded"
    static let challengeFailed = "sepa:tokenize:challenge:failed"
}
