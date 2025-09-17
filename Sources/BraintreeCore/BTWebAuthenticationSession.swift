import Foundation
import AuthenticationServices

/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public class BTWebAuthenticationSession: NSObject {

    // MARK: - Public Properties
    
    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public var prefersEphemeralWebBrowserSession: Bool?
    
    // MARK: - Private Properties
    
    private let sessionQueue = DispatchQueue(label: "com.braintree.webAuthenticationSession.queue")
    private var currentSession: ASWebAuthenticationSession?
    
    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidComplete: @escaping (URL?, Error?) -> Void,
        sessionDidAppear: @escaping (Bool) -> Void,
        sessionDidCancel: @escaping () -> Void,
        sessionDidDuplicate: @escaping () -> Void = { }
    ) {
        
        let shouldStartSession = sessionQueue.sync {
            if currentSession != nil {
                return false
            }
            
            // Create the session but don't start it yet
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: BTCoreConstants.callbackURLScheme
            ) { [weak self] url, error in
                guard let self else { return }
                
                self.sessionQueue.sync {
                    self.currentSession = nil
                }
                
                if let error = error as? NSError, error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                    sessionDidCancel()
                } else {
                    sessionDidComplete(url, error)
                }
            }
            
            session.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession ?? false
            session.presentationContextProvider = context
            
            currentSession = session
            return true
        }
        
        guard shouldStartSession else {
            sessionDidDuplicate()
            return
        }
        
        // Safe to access because we're holding a reference in the local scope
        if let session = sessionQueue.sync(execute: { currentSession }) {
            DispatchQueue.main.async {
                sessionDidAppear(session.start())
            }
        }
    }
}
