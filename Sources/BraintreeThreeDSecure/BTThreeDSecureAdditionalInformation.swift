import Foundation

/// Additional information for a 3DS lookup. Used in 3DS 2.0+ flows.
@objcMembers public class BTThreeDSecureAdditionalInformation: NSObject {

    // MARK: - Public Properties

    /// Optional. The shipping address used for verification
    public var shippingAddress: BTThreeDSecurePostalAddress?

    /// Optional. The 2-digit string indicating the shipping method chosen for the transaction
    ///
    /// Possible Values:
    /// - 01:  Ship to cardholder billing address
    /// - 02: Ship to another verified address on file with merchant
    /// - 03: Ship to address that is different than billing address
    /// - 04: Ship to store (store address should be populated on request)
    /// - 05: Digital goods
    /// - 06: Travel and event tickets, not shipped
    /// - 07: Other
    public var shippingMethodIndicator: String?

    /// Optional. The 3-letter string representing the merchant product code
    ///
    /// Possible Values:
    /// - AIR: Airline
    /// - GEN: General Retail
    /// - DIG: Digital Goods
    /// - SVC: Services
    /// - RES: Restaurant
    /// - TRA: Travel
    /// - DSP: Cash Dispensing
    /// - REN: Car Rental
    /// - GAS: Fueld
    /// - LUX: Luxury Retail
    /// - ACC: Accommodation Retail
    /// - TBD: Other
    public var productCode: String?

    /// Optional. The 2-digit number indicating the delivery timeframe
    ///
    /// Possible values:
    /// - 01: Electronic delivery
    /// - 02: Same day shipping
    /// - 03: Overnight shipping
    /// - 04: Two or more day shipping
    public var deliveryTimeframe: String?

    /// Optional. For electronic delivery, email address to which the merchandise was delivered
    public var deliveryEmail: String?

    /// Optional. The 2-digit number indicating whether the cardholder is reordering previously purchased merchandise
    ///
    /// Possible values:
    /// - 01: First time ordered
    /// - 02: Reordered
    public var reorderIndicator: String?

    ///  Optional. The 2-digit number indicating whether the cardholder is placing an order with a future availability or release date
    ///
    ///  Possible values:
    /// - 01: Merchandise available
    /// - 02: Future availability
    public var preorderIndicator: String?

    /// Optional. The 8-digit number (format: YYYYMMDD) indicating expected date that a pre-ordered purchase will be available
    public var preorderDate: String?

    /// Optional. The purchase amount total for prepaid gift cards in major units
    public var giftCardAmount: String?

    /// Optional. ISO 4217 currency code for the gift card purchased
    public var giftCardCurrencyCode: String?

    /// Optional. Total count of individual prepaid gift cards purchased
    public var giftCardCount: String?

    ///  Optional. The 2-digit value representing the length of time since the last change to the cardholder account. This includes shipping address, new payment account or new user added.
    ///
    /// Possible values:
    /// - 01: Changed during transaction
    /// - 02: Less than 30 days
    /// - 03: 30-60 days
    /// - 04: More than 60 days
    public var accountAgeIndicator: String?

    /// Optional. The 8-digit number (format: YYYYMMDD) indicating the date the cardholder's account was last changed.
    /// This includes changes to the billing or shipping address, new payment accounts or new users added.
    public var accountCreateDate: String?

    /// Optional. The 2-digit value representing the length of time since the last change to the cardholder account. This includes shipping address, new payment account or new user added.
    ///
    /// Possible values:
    /// - 01: Changed during transaction
    /// - 02: Less than 30 days
    /// - 03: 30-60 days
    /// - 04: More than 60 days
    public var accountChangeIndicator: String?

    /// Optional. The 8-digit number (format: YYYYMMDD) indicating the date the cardholder's account was last changed.
    /// This includes changes to the billing or shipping address, new payment accounts or new users added.
    public var accountChangeDate: String?

    /// Optional. The 2-digit value representing the length of time since the cardholder changed or reset the password on the account.
    ///
    /// Possible values:
    /// - 01: No change
    /// - 02: Changed during transaction
    /// - 03: Less than 30 days
    /// - 04: 30-60 days
    /// - 05: More than 60 days
    public var accountPwdChangeIndicator: String?

    /// Optional. The 8-digit number (format: YYYYMMDD) indicating the date the cardholder last changed or reset password on account.
    public var accountPwdChangeDate: String?

    /// Optional. The 2-digit value indicating when the shipping address used for transaction was first used.
    ///
    /// Possible values:
    /// - 01: This transaction
    /// - 02: Less than 30 days
    /// - 03: 30-60 days
    /// - 04: More than 60 days
    public var shippingAddressUsageIndicator: String?

    /// Optional. The 8-digit number (format: YYYYMMDD) indicating the date when the shipping address used for this transaction was first used.
    public var shippingAddressUsageDate: String?

    /// Optional. Number of transactions (successful or abandoned) for this cardholder account within the last 24 hours.
    public var transactionCountDay: String?

    /// Optional. Number of transactions (successful or abandoned) for this cardholder account within the last year.
    public var transactionCountYear: String?

    /// Optional. Number of add card attempts in the last 24 hours.
    public var addCardAttempts: String?

    /// Optional. Number of purchases with this cardholder account during the previous six months.
    public var accountPurchases: String?

    /// Optional. The 2-digit value indicating whether the merchant experienced suspicious activity (including previous fraud) on the account.
    ///
    /// Possible values:
    /// - 01: No suspicious activity
    /// - 02: Suspicious activity observed
    public var fraudActivity: String?

    ///  Optional. The 2-digit value indicating if the cardholder name on the account is identical to the shipping name used for the transaction.
    ///
    ///  Possible values:
    ///  - 01: Account name identical to shipping name
    ///  - 02: Account name different than shipping name
    public var shippingNameIndicator: String?

    ///  Optional. The 2-digit value indicating the length of time that the payment account was enrolled in the merchant account.
    ///
    ///  Possible values:
    ///  - 01: No account (guest checkout)
    ///  - 02: During the transaction
    ///  - 03: Less than 30 days
    ///  - 04: 30-60 days
    ///  - 05: More than 60 days
    public var paymentAccountIndicator: String?

    /// Optional. The 8-digit number (format: YYYYMMDD) indicating the date the payment account was added to the cardholder account.
    public var paymentAccountAge: String?

    /// Optional. The 1-character value (Y/N) indicating whether cardholder billing and shipping addresses match.
    public var addressMatch: String?

    /// Optional. Additional cardholder account information.
    public var accountID: String?

    /// Optional. The IP address of the consumer. IPv4 and IPv6 are supported.
    public var ipAddress: String?

    /// Optional. Brief description of items purchased.
    public var orderDescription: String?

    /// Optional. Unformatted tax amount without any decimalization (ie. $123.67 = 12367).
    public var taxAmount: String?

    /// Optional. The exact content of the HTTP user agent header.
    public var userAgent: String?

    /// Optional. The 2-digit number indicating the type of authentication request.
    ///
    /// Possible values:
    /// - 02: Recurring transaction
    /// - 03: Installment transaction
    public var authenticationIndicator: String?

    /// Optional.  An integer value greater than 1 indicating the maximum number of permitted authorizations for installment payments.
    public var installment: String?

    /// Optional. The 14-digit number (format: YYYYMMDDHHMMSS) indicating the date in UTC of original purchase.
    public var purchaseDate: String?

    /// Optional. The 8-digit number (format: YYYYMMDD) indicating the date after which no further recurring authorizations should be performed.
    public var recurringEnd: String?

    /// Optional. Integer value indicating the minimum number of days between recurring authorizations.
    /// A frequency of monthly is indicated by the value 28. Multiple of 28 days will be used to indicate months (ex. 6 months = 168).
    public var recurringFrequency: String?

    /// Optional. The 2-digit number of minutes (minimum 05) to set the maximum amount of time for all 3DS 2.0 messages to be communicated between all components.
    public var sdkMaxTimeout: String?

    /// Optional. The work phone number used for verification. Only numbers; remove dashes, parenthesis and other characters.
    public var workPhoneNumber: String?

    // MARK: - Internal Methods

    func asParameters() -> [String: String] {
        var parameters: [String: String?] = [
            "shippingMethodIndicator": shippingMethodIndicator,
            "productCode": productCode,
            "deliveryTimeframe": deliveryTimeframe,
            "deliveryEmail": deliveryEmail,
            "reorderIndicator": reorderIndicator,
            "preorderIndicator": preorderIndicator,
            "preorderDate": preorderDate,
            "giftCardAmount": giftCardAmount,
            "giftCardCurrencyCode": giftCardCurrencyCode,
            "giftCardCount": giftCardCount,
            "accountAgeIndicator": accountAgeIndicator,
            "accountCreateDate": accountCreateDate,
            "accountChangeIndicator": accountChangeIndicator,
            "accountChangeDate": accountChangeDate,
            "accountPwdChangeIndicator": accountPwdChangeIndicator,
            "accountPwdChangeDate": accountPwdChangeDate,
            "shippingAddressUsageIndicator": shippingAddressUsageIndicator,
            "shippingAddressUsageDate": shippingAddressUsageDate,
            "transactionCountDay": transactionCountDay,
            "transactionCountYear": transactionCountYear,
            "addCardAttempts": addCardAttempts,
            "accountPurchases": accountPurchases,
            "fraudActivity": fraudActivity,
            "shippingNameIndicator": shippingNameIndicator,
            "paymentAccountIndicator": paymentAccountIndicator,
            "paymentAccountAge": paymentAccountAge,
            "addressMatch": addressMatch,
            "accountId": accountID,
            "ipAddress": ipAddress,
            "orderDescription": orderDescription,
            "taxAmount": taxAmount,
            "userAgent": userAgent,
            "authenticationIndicator": authenticationIndicator,
            "installment": installment,
            "purchaseDate": purchaseDate,
            "recurringEnd": recurringEnd,
            "recurringFrequency": recurringFrequency,
            "sdkMaxTimeout": sdkMaxTimeout,
            "workPhoneNumber": workPhoneNumber
        ]

        let finalShippingAddress = shippingAddress?.asParameters(withPrefix: "shipping")
        parameters = parameters.merging(finalShippingAddress ?? [:]) { $1 }

        // Remove all nil values and their key
        let filteredParameters: [String: String] = parameters.compactMapValues { $0 }

        return filteredParameters
    }
}
