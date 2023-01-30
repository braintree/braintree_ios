#if canImport(BraintreeCore)
import BraintreeCore
#endif

#if canImport(BraintreePayPal)
import BraintreePayPal
#endif

@objcMembers public class BTPayPalNativeRequest: NSObject {

    // MARK: - Public Properties
    // next_major_version: subclass BTPayPalRequest once BraintreePayPal is in Swift.

    /// Optional: The line items for this transaction. It can include up to 249 line items.
    public var lineItems: [BTPayPalLineItem]?

    /// Defaults to false. When set to true, the shipping address selector will be displayed.
    public var isShippingAddressRequired: Bool

    /// Optional: The merchant name displayed inside of the PayPal flow; defaults to the company name on your Braintree account
    public var displayName: String?

    ///  Optional: A locale code to use for the transaction.
    ///  - Note: Supported locales are:
    ///
    /// `da_DK`,
    /// `de_DE`,
    /// `en_AU`,
    /// `en_GB`,
    /// `en_US`,
    /// `es_ES`,
    /// `es_XC`,
    /// `fr_CA`,
    /// `fr_FR`,
    /// `fr_XC`,
    /// `id_ID`,
    /// `it_IT`,
    /// `ja_JP`,
    /// `ko_KR`,
    /// `nl_NL`,
    /// `no_NO`,
    /// `pl_PL`,
    /// `pt_BR`,
    /// `pt_PT`,
    /// `ru_RU`,
    /// `sv_SE`,
    /// `th_TH`,
    /// `tr_TR`,
    /// `zh_CN`,
    /// `zh_HK`,
    /// `zh_TW`,
    /// `zh_XC`.
    public var localeCode: String?

    /// Defaults to false. Set to true to enable user editing of the shipping address.
    /// - Note: Only applies when `shippingAddressOverride` is set.
    public var isShippingAddressEditable: Bool

    /// Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
    public var shippingAddressOverride: BTPostalAddress?

    /// Optional: A risk correlation ID created with Set Transaction Context on your server.
    public var riskCorrelationID: String?

    /// Optional: A non-default merchant account to use for tokenization.
    public var merchantAccountID: String?

    // MARK: - Internal Properties

    var hermesPath: String

    var paymentType: BTPayPalPaymentType

    // MARK: - Initializer

    init(
        hermesPath: String,
        paymentType: BTPayPalPaymentType,
        lineItems: [BTPayPalLineItem]? = nil,
        isShippingAddressRequired: Bool = false,
        displayName: String? = nil,
        localeCode: String? = nil,
        isShippingAddressEditable: Bool = false,
        shippingAddressOverride: BTPostalAddress? = nil,
        riskCorrelationID: String? = nil,
        merchantAccountID: String? = nil
    ) {
        self.hermesPath = hermesPath
        self.paymentType = paymentType
        self.lineItems = lineItems
        self.isShippingAddressRequired = isShippingAddressRequired
        self.displayName = displayName
        self.localeCode = localeCode
        self.isShippingAddressEditable = isShippingAddressEditable
        self.shippingAddressOverride = shippingAddressOverride
        self.riskCorrelationID = riskCorrelationID
        self.merchantAccountID = merchantAccountID
    }

    // MARK: - Internal Methods

    func constructParameters(from configuration: BTConfiguration, withRequest request: Any) -> [AnyHashable: Any] {
        let baseParameters = getBaseParameters(with: configuration)

        switch paymentType {
        case .checkout:
            guard let request = request as? BTPayPalNativeCheckoutRequest else { return [:] }
            var checkoutParameters: [String: Any] = [
                "intent": request.intentAsString,
                "amount": request.amount,
                "offer_pay_later": request.offerPayLater
            ]

            if let currencyCode = request.currencyCode ?? configuration.json["paypal"]["currencyIsoCode"].asString() {
                checkoutParameters["currency_iso_code"] = currencyCode
            }

            if request.requestBillingAgreement != false {
                checkoutParameters["request_billing_agreement"] = request.requestBillingAgreement

                if request.billingAgreementDescription != nil {
                    checkoutParameters["billing_agreement_details"] = ["description": request.billingAgreementDescription]
                }
            }

            if shippingAddressOverride != nil {
                checkoutParameters["line1"] = shippingAddressOverride?.streetAddress
                checkoutParameters["line2"] = shippingAddressOverride?.extendedAddress
                checkoutParameters["city"] = shippingAddressOverride?.locality
                checkoutParameters["state"] = shippingAddressOverride?.region
                checkoutParameters["postal_code"] = shippingAddressOverride?.postalCode
                checkoutParameters["country_code"] = shippingAddressOverride?.countryCodeAlpha2
                checkoutParameters["recipient_name"] = shippingAddressOverride?.recipientName
            }

            return baseParameters.merging(checkoutParameters) { $1 }
        case .vault:
            guard let request = request as? BTPayPalNativeVaultRequest else { return [:] }
            var vaultParameters: [String: Any] = ["offer_paypal_credit": request.offerCredit]

            if request.billingAgreementDescription != nil {
                vaultParameters["description"] = request.billingAgreementDescription
            }

            // Should only include shipping params if they exist
            if shippingAddressOverride != nil {
                let shippingAddressParameters: [String: String?] = [
                    "line1": shippingAddressOverride?.streetAddress,
                    "line2": shippingAddressOverride?.extendedAddress,
                    "city": shippingAddressOverride?.locality,
                    "state": shippingAddressOverride?.region,
                    "postal_code": shippingAddressOverride?.postalCode,
                    "country_code": shippingAddressOverride?.countryCodeAlpha2,
                    "recipient_name": shippingAddressOverride?.recipientName,
                ]

                vaultParameters["shipping_address"] = shippingAddressParameters
            }

            return baseParameters.merging(vaultParameters) { $1 }
        @unknown default:
            return [:]
        }
    }

    func getBaseParameters(with configuration: BTConfiguration) -> [AnyHashable: Any] {
        let callbackHostAndPath = "onetouch/v1/"
        let callbackURLScheme = "sdk.ios.braintree"

        let lineItemsArray = lineItems?.compactMap { $0.requestParameters() } ?? []

        let experienceProfile: [String: Any?] = [
            "no_shipping": !isShippingAddressRequired,
            "brand_name": displayName ?? configuration.json["paypal"]["displayName"].asString(),
            "locale_code": localeCode,
            "address_override": shippingAddressOverride != nil ? !isShippingAddressEditable : false
        ]

        let baseParams: [AnyHashable: Any?] = [
          // Base values from BTPayPalNativeRequest
          "correlation_id": riskCorrelationID,
          "merchant_account_id": merchantAccountID,
          "line_items": lineItemsArray,
          "return_url": String(format: "%@://%@success", callbackURLScheme, callbackHostAndPath),
          "cancel_url": String(format: "%@://%@cancel", callbackURLScheme, callbackHostAndPath),
          "experience_profile": experienceProfile.compactMapValues { $0 }
        ]

        return baseParams.compactMapValues { $0 }
    }
}
