import Foundation

///  Protocol for receiving SEPA Direct Debit lifecycle messages when web session is started and completed.
@objc public protocol BTSEPADirectDebitDelegate: AnyObject {
    
    /// The BTSEPADirectDebitClient started a web session.
    ///
    /// - Parameters:
    ///    - sepaDirectDebitClient: the `BTSEPADirectDebitClient` associated with the delegate.
    ///    - didCompleteWebSession: indicates that a web session has started.
    func sepaDirectDebit(_ sepaDirectDebitClient: BTSEPADirectDebitClient, didStartWebSession: Bool)
    
    /// The BTSEPADirectDebitClient completed a web session.
    ///
    /// - Parameters:
    ///    - sepaDirectDebitClient: the `BTSEPADirectDebitClient` associated with the delegate.
    ///    - didCompleteWebSession: indicates that a web session has completed.
    func sepaDirectDebit(_ sepaDirectDebitClient: BTSEPADirectDebitClient, didCompleteWebSession: Bool)
}
