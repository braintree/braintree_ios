#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTApplePayCardNonce : BTPaymentMethodNonce

/*!
 @brief The BIN data for the card number associated with this nonce.
 */
@property (nonatomic, readonly, strong) BTBinData *binData;

- (nullable instancetype)initWithNonce:(NSString *)nonce localizedDescription:(nullable NSString *)description type:(NSString *)type json:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END
