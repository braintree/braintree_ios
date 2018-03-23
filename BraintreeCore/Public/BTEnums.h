/**
 Card type
 */
typedef NS_ENUM(NSInteger, BTCardNetwork) {
    /// Unknown card
    BTCardNetworkUnknown = 0,

    /// American Express
    BTCardNetworkAMEX,

    /// Diners Club
    BTCardNetworkDinersClub,

    /// Discover
    BTCardNetworkDiscover,

    /// Mastercard
    BTCardNetworkMasterCard,

    /// Visa
    BTCardNetworkVisa,

    /// JCB
    BTCardNetworkJCB,

    /// Laser
    BTCardNetworkLaser,

    /// Maestro
    BTCardNetworkMaestro,

    /// Union Pay
    BTCardNetworkUnionPay,

    /// Solo
    BTCardNetworkSolo,

    /// Switch
    BTCardNetworkSwitch,

    /// UK Maestro
    BTCardNetworkUKMaestro,
};
