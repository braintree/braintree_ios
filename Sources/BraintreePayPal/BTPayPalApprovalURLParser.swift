import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The type of PayPal authentication flow to occur
enum PayPalRedirectType {
    
    /// The in-app browser (ASWebAuthenticationSession) web checkout flow
    case webBrowser(url: URL)
    
    /// The universal link flow, switching out of the merchant app into the native PayPal app
    case payPalApp(url: URL)
}

/// Parses response body from `/v1/paypal_hermes/*` POST requests to determine the `PayPalRedirectType`
struct BTPayPalApprovalURLParser {
    
    var redirectType: PayPalRedirectType
    
    var pairingID: String? {
        switch redirectType {
        case .webBrowser(let url), .payPalApp(let url):
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?
                .queryItems?
                .compactMap { $0 }

            if let baToken = queryItems?.filter({ $0.name == "ba_token" }).first?.value, !baToken.isEmpty {
                return baToken
            } else if let ecToken = queryItems?.filter({ $0.name == "token" }).first?.value, !ecToken.isEmpty {
                return ecToken
            }

            return nil
        }
    }
    
    init?(body: BTJSON) {
        if let payPalAppRedirectURL = body["agreementSetup"]["paypalAppApprovalUrl"].asURL() {
            redirectType = .payPalApp(url: payPalAppRedirectURL)
        } else if let approvalURL = body["paymentResource"]["redirectUrl"].asURL() ??
            body["agreementSetup"]["approvalUrl"].asURL() {
            redirectType = .webBrowser(url: approvalURL)
        } else {
            return nil
        }
    }
}
