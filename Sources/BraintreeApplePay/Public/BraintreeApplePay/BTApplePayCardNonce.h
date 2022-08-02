#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class BTJSON;

/**
 Contains information about a tokenized Apple Pay card.
 */
@interface BTApplePayCardNonce : NSObject

/**
 The BIN data for the card number associated with this nonce.
 */
@property (nonatomic, readonly, strong) BTBinData *binData;

@property (nonatomic, readonly, strong) NSString * _Nonnull nonce;

@property (nonatomic, readonly, strong) NSString * _Nullable type;

@property (nonatomic, readwrite, assign) BOOL isDefault;

/**
 Used to initialize a `BTApplePayCardNonce` with parameters.
 */
- (nullable instancetype)initWithJSON:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END
