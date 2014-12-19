@import Foundation;

#import "BTClient.h"
#import "BTPaymentMethodCreationDelegate.h"

@interface BTThreeDSecure : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (void)verifyCardWithNonce:(NSString *)nonce amount:(NSDecimalNumber *)amount;

@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

@end
