import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

enum PayPalRedirectType {
    case webBrowser(url: URL)
    case payPalApp(url: URL)
}

struct ApprovalURLParser {
    
    var redirectType: PayPalRedirectType
    
    var pairingID: String? {
        switch redirectType {
        case .webBrowser(let url), .payPalApp(let url):
            let url = URLComponents(url: url, resolvingAgainstBaseURL: true)
            return url?.queryItems?.first(where: { $0.name == "token" || $0.name == "ba_token" })?.value
        }
    }
    
    init?(body: BTJSON) {
        if let paypalAppRedirectUrl = body["paymentResource"]["paypalAppApprovalUrl"].asURL() {
            redirectType = .payPalApp(url: paypalAppRedirectUrl)
        } else if let approvalURL = body["paymentResource"]["redirectUrl"].asURL() ??
            body["agreementSetup"]["approvalUrl"].asURL() {
            redirectType = .webBrowser(url: approvalURL)
        } else {
            return nil
        }
    }
}
