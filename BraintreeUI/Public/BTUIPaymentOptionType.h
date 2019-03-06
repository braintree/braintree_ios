/**
 Credit card types
*/
typedef NS_ENUM(NSInteger, BTUIPaymentOptionType) {
    /// Unknown
    BTUIPaymentOptionTypeUnknown = 0,

    /// American Express
    BTUIPaymentOptionTypeAMEX,

    /// Diners Club
    BTUIPaymentOptionTypeDinersClub,

    /// Discover
    BTUIPaymentOptionTypeDiscover,

    /// Mastercard
    BTUIPaymentOptionTypeMasterCard,

    /// Visa
    BTUIPaymentOptionTypeVisa,

    /// JCB
    BTUIPaymentOptionTypeJCB,

    /// Laser
    BTUIPaymentOptionTypeLaser,

    /// Maestro
    BTUIPaymentOptionTypeMaestro,

    /// Union Pay
    BTUIPaymentOptionTypeUnionPay,

    /// Solo
    BTUIPaymentOptionTypeSolo,

    /// Switch
    BTUIPaymentOptionTypeSwitch,

    /// UK Maestro
    BTUIPaymentOptionTypeUKMaestro,

    /// PayPal
    BTUIPaymentOptionTypePayPal,

    /// Coinbase
    BTUIPaymentOptionTypeCoinbase,

    /// Venmo
    BTUIPaymentOptionTypeVenmo,
};
