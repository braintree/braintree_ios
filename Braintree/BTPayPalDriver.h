#import <Foundation/Foundation.h>
#import "BTConfiguration.h"
#import "BTTokenizedPayPalAccount.h"
#import "BTTokenizedPayPalCheckout.h"
#import "BTPayPalCheckoutRequest.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTPayPalDriver : NSObject

- (instancetype)initWithConfiguration:(BTConfiguration *)configuration;

- (void)authorizeAccountWithCompletion:(void (^)(BTTokenizedPayPalAccount *tokenizedPayPalAccount, NSError *error))completionBlock;

- (void)authorizeAccountWithAdditionalScopes:(NSSet<NSString *> *)additionalScopes completion:(void (^)(BTTokenizedPayPalAccount *, NSError *))completionBlock;

- (void)checkoutWithCheckoutRequest:(BTPayPalCheckoutRequest *)checkoutRequest completion:(void (^)(BTTokenizedPayPalCheckout *tokenizedPayPalCheckout, NSError *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
