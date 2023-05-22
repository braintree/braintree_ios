import Foundation
import AuthenticationServices

#if canImport(BraintreeCore)
import BraintreeCore
#endif

class WebAuthenticationSession: NSObject {
    func start(
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
