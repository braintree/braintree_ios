import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class WebAuthenticationSession: NSObject {

    var authenticationSession: ASWebAuthenticationSession?

    func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (URL?, Error?) -> Void
    ) {
        self.authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: BTCoreConstants.callbackURLScheme,
            completionHandler: completion
        )

        authenticationSession?.prefersEphemeralWebBrowserSession = true
        authenticationSession?.presentationContextProvider = context

        authenticationSession?.start()
    }
}
