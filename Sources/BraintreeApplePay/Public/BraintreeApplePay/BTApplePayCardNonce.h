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
 The last two digits of the card associated with this nonce, if available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *dpanLastTwo;

/**
 Used to initialize a `BTApplePayCardNonce` with parameters.
 */
- (nullable instancetype)initWithJSON:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END
