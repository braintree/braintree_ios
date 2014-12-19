@import Foundation;

#import "BTClient.h"
#import "BTPaymentMethodCreationDelegate.h"

@interface BTThreeDSecure : NSObject

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

- (void)verifyCardWithNonce:(NSString *)nonce amount:(NSDecimalNumber *)amount;

- (void)verifyCard:(BTCardPaymentMethod *)card amount:(NSDecimalNumber *)amount;

- (void)verifyCardWithDetails:(BTClientCardRequest *)details amount:(NSDecimalNumber *)amount;

@end
