import Foundation

/// Protocol for ThreeDSecure Request flow
@objc public protocol BTThreeDSecureRequestDelegate {
    
    ///  Required delegate method which returns the ThreeDSecure lookup result before the flow continues.
    ///  Use this to do any UI preparation or custom lookup result handling. Use the `next()` callback to continue the flow.
    /// - Parameters:
    ///   - request: The `BTThreeDSecureRequest` associated with the lookup.
    ///   - result: `BTThreeDSecureResult` details.
    ///   - next: Must be called to continue the flow.
    @objc func onLookupComplete(_ request: BTThreeDSecureRequest, lookupResult: BTThreeDSecureResult, next: @escaping () -> Void)
}
