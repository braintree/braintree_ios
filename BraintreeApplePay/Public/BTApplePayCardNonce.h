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

- (instancetype)initWithNonce:(NSString *)nonce
         localizedDescription:(NSString *)description
                         type:(NSString *)type
                    isDefault:(BOOL)isDefault
                         json:(BTJSON *)json;

@end

NS_ASSUME_NONNULL_END
