#import <BraintreeCore/BraintreeCore.h>

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
 Used to initialize a `BTApplePayCardNonce` with parameters.
 */
- (nullable instancetype)initWithNonce:(NSString *)nonce type:(NSString *)type json:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END
