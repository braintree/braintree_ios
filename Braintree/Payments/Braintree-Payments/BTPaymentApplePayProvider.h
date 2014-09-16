@import Foundation;

@class BTClient;
#import "BTPaymentMethodCreationDelegate.h"

@interface BTPaymentApplePayProvider : NSObject

- (instancetype)initWithClient:(BTClient *)client;

@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

- (BOOL)canAuthorizeApplePayPayment;
- (void)authorizeApplePay;

@end
