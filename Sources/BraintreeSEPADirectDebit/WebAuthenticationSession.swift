import Foundation
import AuthenticationServices

class WebAuthenticationSession: NSObject {

    var authenticationSession: ASWebAuthenticationSession?
    
    @available(iOS 13.0, *)
    private(set) lazy var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil

    @available(iOS 13.0, *)
    func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (URL?, Error?) -> Void
    ) {
        self.authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: Bundle.main.bundleIdentifier,
            completionHandler: completion
        )

        authenticationSession?.prefersEphemeralWebBrowserSession = true
        authenticationSession?.presentationContextProvider = context

        authenticationSession?.start()
    }
    
    func start(
        url: URL,
        completion: @escaping (URL?, Error?) -> Void
    ) {
        self.authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: Bundle.main.bundleIdentifier,
            completionHandler: completion
        )

        authenticationSession?.start()
    }
}
