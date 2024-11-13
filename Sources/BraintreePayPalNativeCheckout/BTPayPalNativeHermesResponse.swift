import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTPayPalNativeHermesResponse {

    let orderID: String

    init?(json: BTJSON?) {
        guard let json = json else { return nil }

        let redirectURL = json["paymentResource"]["redirectUrl"].asURL()
        let approvalURL = json["agreementSetup"]["approvalUrl"].asURL()

        guard let url = redirectURL ?? approvalURL else { return nil }

        let token = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "token" || $0.name == "ba_token" }?
            .value

        guard let orderID = token else { return nil }

        self.orderID = orderID
    }
}
