import UIKit

///  :nodoc:
///  Fetches information about which payment methods are preferred on the device.
///  Used to determine which payment methods are given preference in your UI, not whether they are presented entirely.
///  This class is currently in beta and may change in future releases.
@objcMembers public class BTPreferredPaymentMethods: NSObject {

    // MARK: - Internal Properties

    var application: UIApplication = UIApplication.shared

    private let apiClient: BTAPIClient

    // MARK: - Initializer

    /// Creates an instance of BTPreferredPaymentMethods.
    /// - Parameter apiClient: An API client
    @objc(initWithAPIClient:)
    public init(apiClient: BTAPIClient) {
        self.apiClient = apiClient
    }

    // MARK: - Public Methods

    ///  Fetches information about which payment methods are preferred on the device.
    /// - Parameter completion: A completion block that is invoked when preferred payment methods are available.
    public func fetch(_ completion: @escaping (BTPreferredPaymentMethodsResult) -> Void) {
        let venmoURL: URL = URL(string: "com.venmo.touch.v2://")!
        let isVenmoInstalled: Bool = application.canOpenURL(venmoURL)

        apiClient.sendAnalyticsEvent("ios.preferred-payment-methods.venmo.app-installed \(isVenmoInstalled)")

        if application.canOpenURL(URL(string: "paypal://")!) {
            let result: BTPreferredPaymentMethodsResult = BTPreferredPaymentMethodsResult()
            result.isPayPalPreferred = true
            result.isVenmoPreferred = isVenmoInstalled

            apiClient.sendAnalyticsEvent("ios.preferred-payment-methods.paypal.app-installed.true")
            completion(result)
            return
        }

        apiClient.fetchOrReturnRemoteConfiguration { configuration, error in
            if error == nil && configuration?.isGraphQLEnabled != nil {
                let parameters: [String: Any] = ["query": "query PreferredPaymentMethods { preferredPaymentMethods { paypalPreferred } }"]

                self.apiClient.post("", parameters: parameters) { body, response, error in
                    let result = BTPreferredPaymentMethodsResult(json: body, venmoInstalled: isVenmoInstalled)

                    if error != nil || body == nil {
                        if let error = error as? NSError, error.code == BTCoreConstants.networkConnectionLostCode {
                            self.apiClient.sendAnalyticsEvent("ios.preferred-payment-methods.network-connection.failure")
                        }

                        self.apiClient.sendAnalyticsEvent("ios.preferred-payment-methods.api-error")
                    } else {
                        self.apiClient.sendAnalyticsEvent("ios.preferred-payment-methods.paypal.api-detected.\(result.isPayPalPreferred)")
                    }
                    completion(result)
                }
            } else {
                let result = BTPreferredPaymentMethodsResult()
                result.isPayPalPreferred = false
                result.isVenmoPreferred = isVenmoInstalled

                if error != nil {
                    self.apiClient.sendAnalyticsEvent("ios.preferred-payment-methods.api-error")
                } else {
                    self.apiClient.sendAnalyticsEvent("ios.preferred-payment-methods.api-disabled")
                }
                completion(result)
            }
        }
    }
}
