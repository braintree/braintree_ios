import Foundation
import AuthenticationServices

/// :nodoc: This class is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public class BTWebAuthenticationSession: NSObject {

    /// :nodoc: This property is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public var prefersEphemeralWebBrowserSession: Bool?

    /// :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidComplete: @escaping (URL?, Error?) -> Void,
        sessionDidAppear: @escaping (Bool) -> Void,
        sessionDidCancel: @escaping () -> Void
    ) {
        let authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: BTCoreConstants.callbackURLScheme
        ) { url, error in
            if let error = error as? NSError, error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                sessionDidCancel()
            } else {
                sessionDidComplete(url, error)
            }
        }

        authenticationSession.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession ?? false

        authenticationSession.presentationContextProvider = context
        DispatchQueue.main.async {
            sessionDidAppear(authenticationSession.start())
        }
    }
}
