import Foundation

/// Additional information for a 3DS lookup. Used in 3DS 2.0+ flows.
@objcMembers public class BTThreeDSecureAdditionalInformation: NSObject {

    // MARK: - Internal Properties

    let accountAgeIndicator: String?
    let accountChangeDate: String?
    let accountChangeIndicator: String?
    let accountCreateDate: String?
    let accountID: String?
    let accountPurchases: String?
    let accountPwdChangeDate: String?
    let accountPwdChangeIndicator: String?
    let addCardAttempts: String?
    let addressMatch: String?
    let authenticationIndicator: String?
    let deliveryEmail: String?
    let deliveryTimeframe: String?
    let fraudActivity: String?
    let giftCardAmount: String?
    let giftCardCount: String?
    let giftCardCurrencyCode: String?
    let installment: String?
    let ipAddress: String?
    let orderDescription: String?
    let paymentAccountAge: String?
    let paymentAccountIndicator: String?
    let preorderDate: String?
    let productCode: String?
    let preorderIndicator: String?
    let purchaseDate: String?
    let recurringEnd: String?
    let recurringFrequency: String?
    let reorderIndicator: String?
    let sdkMaxTimeout: String?
    let shippingAddress: BTThreeDSecurePostalAddress?
    let shippingAddressUsageDate: String?
    let shippingAddressUsageIndicator: String?
    let shippingMethodIndicator: String?
    let shippingNameIndicator: String?
    let taxAmount: String?
    let transactionCountDay: String?
    let transactionCountYear: String?
    let userAgent: String?
    let workPhoneNumber: String?

    /// Additional information for a 3DS lookup. Used in 3DS 2.0+ flows.
    /// - Parameters:
    ///   - accountAgeIndicator: Optional. The 2-digit value representing the length of time since the last change to the cardholder account. This includes shipping address, new payment account or new user added.
    ///     Possible values:
    ///     - 01: Changed during transaction
    ///     - 02: Less than 30 days
    ///     - 03: 30-60 days
    ///     - 04: More than 60 days
    ///   - accountChangeDate: Optional. The 8-digit number (format: YYYYMMDD) indicating the date the cardholder's account was last changed. This includes changes to the billing or shipping address, new payment accounts or new users added.
    ///   - accountChangeIndicator: Optional. The 2-digit value representing the length of time since the last change to the cardholder account. This includes shipping address, new payment account or new user added.
    ///     Possible values:
    ///     - 01: Changed during transaction
    ///     - 02: Less than 30 days
    ///     - 03: 30-60 days
    ///     - 04: More than 60 days
    ///   - accountCreateDate: Optional. The 8-digit number (format: YYYYMMDD) indicating the date the cardholder's account was last changed. This includes changes to the billing or shipping address, new payment accounts or new users added.
    ///   - accountID: Optional. Additional cardholder account information.
    ///   - accountPurchases: Optional. Number of purchases with this cardholder account during the previous six months.
    ///   - accountPwdChangeDate: Optional. The 8-digit number (format: YYYYMMDD) indicating the date the cardholder last changed or reset password on account.
    ///   - accountPwdChangeIndicator: Optional. The 2-digit value representing the length of time since the cardholder changed or reset the password on the account.
    ///     Possible values:
    ///     - 01: No change
    ///     - 02: Changed during transaction
    ///     - 03: Less than 30 days
    ///     - 04: 30-60 days
    ///     - 05: More than 60 days
    ///   - addCardAttempts: Optional. Number of add card attempts in the last 24 hours.
    ///   - addressMatch: Optional. The 1-character value (Y/N) indicating whether cardholder billing and shipping addresses match.
    ///   - authenticationIndicator: Optional. The 2-digit number indicating the type of authentication request.
    ///     Possible values:
    ///     - 02: Recurring transaction
    ///     - 03: Installment transaction
    ///   - deliveryTimeframe: Optional. The 2-digit number indicating the delivery timeframe
    ///     Possible values:
    ///     - 01: Electronic delivery
    ///     - 02: Same day shipping
    ///     - 03: Overnight shipping
    ///     - 04: Two or more day shipping
    ///   - fraudActivity: Optional. The 2-digit value indicating whether the merchant experienced suspicious activity (including previous fraud) on the account.
    ///     Possible values:
    ///     - 01: No suspicious activity
    ///     - 02: Suspicious activity observed
    ///   - giftCardAmount: Optional. The purchase amount total for prepaid gift cards in major units
    ///   - giftCardCount: Optional. Total count of individual prepaid gift cards purchased
    ///   - giftCardCurrencyCode: Optional. ISO 4217 currency code for the gift card purchased
    ///   - installment:  Optional. An integer value greater than 1 indicating the maximum number of permitted authorizations for installment payments.
    ///   - ipAddress: Optional. The IP address of the consumer. IPv4 and IPv6 are supported.
    ///   - orderDescription: Optional. Brief description of items purchased.
    ///   - paymentAccountAge: Optional. The 8-digit number (format: YYYYMMDD) indicating the date the payment account was added to the cardholder account.
    ///   - paymentAccountIndicator: Optional. The 2-digit value indicating the length of time that the payment account was enrolled in the merchant account.
    ///     Possible values:
    ///     - 01: No account (guest checkout)
    ///     - 02: During the transaction
    ///     - 03: Less than 30 days
    ///     - 04: 30-60 days
    ///     - 05: More than 60 days
    ///   - preorderDate: Optional. The 8-digit number (format: YYYYMMDD) indicating expected date that a pre-ordered purchase will be available
    ///   - preorderIndicator: Optional. The 2-digit number indicating whether the cardholder is placing an order with a future availability or release date
    ///     Possible values:
    ///     - 01: Merchandise available
    ///     - 02: Future availability
    ///   - productCode: Optional. The 3-letter string representing the merchant product code
    ///     Possible Values:
    ///     - AIR: Airline
    ///     - GEN: General Retail
    ///     - DIG: Digital Goods
    ///     - SVC: Services
    ///     - RES: Restaurant
    ///     - TRA: Travel
    ///     - DSP: Cash Dispensing
    ///     - REN: Car Rental
    ///     - GAS: Fueld
    ///     - LUX: Luxury Retail
    ///     - ACC: Accommodation Retail
    ///     - TBD: Other
    ///   - purchaseDate: Optional. The 14-digit number (format: YYYYMMDDHHMMSS) indicating the date in UTC of original purchase.
    ///   - recurringEnd: Optional. The 8-digit number (format: YYYYMMDD) indicating the date after which no further recurring authorizations should be performed.
    ///   - recurringFrequency: Optional. Integer value indicating the minimum number of days between recurring authorizations.
    ///   - reorderIndicator: Optional. The 2-digit number indicating whether the cardholder is reordering previously purchased merchandise
    ///     Possible values:
    ///     - 01: First time ordered
    ///     - 02: Reordered
    ///   - sdkMaxTimeout: Optional. The 2-digit number of minutes (minimum 05) to set the maximum amount of time for all 3DS 2.0 messages to be communicated between all components.
    ///   - shippingAddress: Optional. The shipping address used for verification
    ///   - shippingAddressUsageDate: Optional. The 8-digit number (format: YYYYMMDD) indicating the date when the shipping address used for this transaction was first used.
    ///   - shippingAddressUsageIndicator: Optional. The 2-digit value indicating when the shipping address used for transaction was first used.
    ///     Possible values:
    ///     - 01: This transaction
    ///     - 02: Less than 30 days
    ///     - 03: 30-60 days
    ///     - 04: More than 60 days
    ///   - shippingMethodIndicator: Optional. The 2-digit string indicating the shipping method chosen for the transaction
    ///     Possible Values:
    ///     - 01:  Ship to cardholder billing address
    ///     - 02: Ship to another verified address on file with merchant
    ///     - 03: Ship to address that is different than billing address
    ///     - 04: Ship to store (store address should be populated on request)
    ///     - 05: Digital goods
    ///     - 06: Travel and event tickets, not shipped
    ///     - 07: Other
    ///   - shippingNameIndicator: Optional. The 2-digit value indicating if the cardholder name on the account is identical to the shipping name used for the transaction.
    ///     Possible values:
    ///     - 01: Account name identical to shipping name
    ///     - 02: Account name different than shipping name
    ///   - taxAmount: Optional. Unformatted tax amount without any decimalization (ie. $123.67 = 12367).
    ///   - transactionCountDay: Optional. Number of transactions (successful or abandoned) for this cardholder account within the last 24 hours.
    ///   - transactionCountYear: Optional. Number of transactions (successful or abandoned) for this cardholder account within the last year.
    ///   - userAgent: Optional. The exact content of the HTTP user agent header.
    ///   - workPhoneNumber: Optional. The work phone number used for verification. Only numbers; remove dashes, parenthesis and other characters.
    public init(
        accountAgeIndicator: String? = nil,
        accountChangeDate: String? = nil,
        accountChangeIndicator: String? = nil,
        accountCreateDate: String? = nil,
        accountID: String? = nil,
        accountPurchases: String? = nil,
        accountPwdChangeDate: String? = nil,
        accountPwdChangeIndicator: String? = nil,
        addCardAttempts: String? = nil,
        addressMatch: String? = nil,
        authenticationIndicator: String? = nil,
        deliveryEmail: String? = nil,
        deliveryTimeframe: String? = nil,
        fraudActivity: String? = nil,
        giftCardAmount: String? = nil,
        giftCardCount: String? = nil,
        giftCardCurrencyCode: String? = nil,
        installment: String? = nil,
        ipAddress: String? = nil,
        orderDescription: String? = nil,
        paymentAccountAge: String? = nil,
        paymentAccountIndicator: String? = nil,
        preorderDate: String? = nil,
        preorderIndicator: String? = nil,
        productCode: String? = nil,
        purchaseDate: String? = nil,
        recurringEnd: String? = nil,
        recurringFrequency: String? = nil,
        reorderIndicator: String? = nil,
        sdkMaxTimeout: String? = nil,
        shippingAddress: BTThreeDSecurePostalAddress? = nil,
        shippingAddressUsageDate: String? = nil,
        shippingAddressUsageIndicator: String? = nil,
        shippingMethodIndicator: String? = nil,
        shippingNameIndicator: String? = nil,
        taxAmount: String? = nil,
        transactionCountDay: String? = nil,
        transactionCountYear: String? = nil,
        userAgent: String? = nil,
        workPhoneNumber: String? = nil
    ) {
        self.accountAgeIndicator = accountAgeIndicator
        self.accountChangeDate = accountChangeDate
        self.accountChangeIndicator = accountChangeIndicator
        self.accountCreateDate = accountCreateDate
        self.accountID = accountID
        self.accountPurchases = accountPurchases
        self.accountPwdChangeDate = accountPwdChangeDate
        self.accountPwdChangeIndicator = accountPwdChangeIndicator
        self.addCardAttempts = addCardAttempts
        self.addressMatch = addressMatch
        self.authenticationIndicator = authenticationIndicator
        self.deliveryEmail = deliveryEmail
        self.deliveryTimeframe = deliveryTimeframe
        self.fraudActivity = fraudActivity
        self.giftCardAmount = giftCardAmount
        self.giftCardCount = giftCardCount
        self.giftCardCurrencyCode = giftCardCurrencyCode
        self.installment = installment
        self.ipAddress = ipAddress
        self.orderDescription = orderDescription
        self.paymentAccountAge = paymentAccountAge
        self.paymentAccountIndicator = paymentAccountIndicator
        self.preorderDate = preorderDate
        self.productCode = productCode
        self.preorderIndicator = preorderIndicator
        self.purchaseDate = purchaseDate
        self.recurringEnd = recurringEnd
        self.recurringFrequency = recurringFrequency
        self.reorderIndicator = reorderIndicator
        self.sdkMaxTimeout = sdkMaxTimeout
        self.shippingAddress = shippingAddress
        self.shippingAddressUsageDate = shippingAddressUsageDate
        self.shippingAddressUsageIndicator = shippingAddressUsageIndicator
        self.shippingMethodIndicator = shippingMethodIndicator
        self.shippingNameIndicator = shippingNameIndicator
        self.taxAmount = taxAmount
        self.transactionCountDay = transactionCountDay
        self.transactionCountYear = transactionCountYear
        self.userAgent = userAgent
        self.workPhoneNumber = workPhoneNumber
    }
}
