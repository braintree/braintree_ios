import Foundation
import AuthenticationServices

/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public class BTWebAuthenticationSession: NSObject {

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public var prefersEphemeralWebBrowserSession: Bool?

    private var currentSession: ASWebAuthenticationSession?
    
    public typealias BAToken = String

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidComplete: @escaping (URL?, Error?, BAToken?) -> Void,
        sessionDidAppear: @escaping (Bool) -> Void,
        sessionDidCancel: @escaping () -> Void,
        sessionDidDuplicate: @escaping (BAToken?) -> Void = { _ in }
    ) {
        let baToken = getBAToken(from: url)
        
        guard currentSession == nil else {
            sessionDidDuplicate(baToken)
            return
        }
        
        currentSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: BTCoreConstants.callbackURLScheme
        ) { url, error in
            self.currentSession = nil
            if let error = error as? NSError, error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                sessionDidCancel()
            } else {
                sessionDidComplete(url, error, baToken)
            }
        }

        currentSession?.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession ?? false
        currentSession?.presentationContextProvider = context
        
        DispatchQueue.main.async {
            sessionDidAppear(self.currentSession?.start() ?? false)
        }
    }
    
    private func getBAToken(from url: URL) -> String? {
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?
            .queryItems?
            .compactMap { $0 }
        
        guard let baToken = queryItems?.first(where: { $0.name == "ba_token" })?.value, !baToken.isEmpty else {
            return nil
        }
        
        return baToken
    }
}
