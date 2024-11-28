import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The type of PayPal authentication flow to occur
enum PayPalRedirectType: Equatable {
    
    /// The in-app browser (ASWebAuthenticationSession) web checkout flow
    case webBrowser(url: URL)
    
    /// The universal link flow, switching out of the merchant app into the native PayPal app
    case payPalApp(url: URL)
}

/// Parses response body from `/v1/paypal_hermes/*` POST requests to determine the `PayPalRedirectType`
struct BTPayPalApprovalURLParser {
    
    let redirectType: PayPalRedirectType

    private let url: URL

    var ecToken: String? {
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?
            .queryItems?
            .compactMap { $0 }

        if let ecToken = queryItems?.first(where: { $0.name == "token" })?.value, !ecToken.isEmpty {
            return ecToken
        }

        return nil
    }

    var baToken: String? {
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?
            .queryItems?
            .compactMap { $0 }

        if let baToken = queryItems?.first(where: { $0.name == "ba_token" })?.value, !baToken.isEmpty {
            return baToken
        }

        return nil
    }

    init?(body: BTJSON) {
        if let payPalAppRedirectURL = body["agreementSetup"]["paypalAppApprovalUrl"].asURL() {
            redirectType = .payPalApp(url: payPalAppRedirectURL)
            url = payPalAppRedirectURL
        } else if let approvalURL = body["paymentResource"]["redirectUrl"].asURL() ??
                    body["agreementSetup"]["approvalUrl"].asURL(), var modifiedURL = approvalURL.modifyHost(["msmaster2intdev51", "msmaster2intdev52"], with: "www.paypal.com") {
//            redirectType = .webBrowser(url: approvalURL)
            modifiedURL.deleteLastPathComponent()
            modifiedURL.appendPathComponent("/app-switch-checkout")
            redirectType = .payPalApp(url: modifiedURL)
            url = modifiedURL
        } else {
            return nil
        }
    }
}

extension URL {
    fileprivate func modifyHost(_ oldHost: [String], with newHost: String) -> URL? {
        // Create URLComponents from the input URL
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let host = components.host else {
            print("Invalid URL or missing host")
            return nil
        }
        for host in oldHost {
            components.host = host.replacingOccurrences(of: host, with: newHost)
        }
        return components.url
    }
}
