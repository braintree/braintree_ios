import Foundation
import AuthenticationServices

///  :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public class BTWebAuthenticationSession: NSObject {

    ///  :nodoc: This method is exposed for internal Braintree use only. Do not use. It is not covered by Semantic Versioning and may change or be removed at any time.
    public func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    ) {
        let authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: BTCoreConstants.callbackURLScheme,
            completionHandler: sessionDidComplete
        )

        authenticationSession.presentationContextProvider = context
        DispatchQueue.main.async {
            sessionDidDisplay(authenticationSession.start())
        }
    }
}
