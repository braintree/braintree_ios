#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information about a tokenized Apple Pay card.
 */
@interface BTApplePayCardNonce : BTPaymentMethodNonce

/**
 The BIN data for the card number associated with this nonce.
 */
@property (nonatomic, readonly, strong) BTBinData *binData;

/**
 This Boolean (available on iOS 16+) indicates whether this tokenized card is a device-specific account number (DPAN) or merchant/cloud token (MPAN). If `isDeviceToken` is `false`, then token type is MPAN.
 */
@property (nonatomic, assign) BOOL isDeviceToken;

/**
 Used to initialize a `BTApplePayCardNonce` with parameters.
 */
- (nullable instancetype)initWithJSON:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END
