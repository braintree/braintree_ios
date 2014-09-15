@import Foundation;

@class BTClient;
@protocol BTPaymentMethodCreationDelegate;

@interface BTPaymentApplePayProvider : NSObject

- (instancetype)initWithClient:(BTClient *)client;

@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

- (BOOL)canAuthorizeApplePayPayment;
- (void)authorizeApplePayPayment;

@end
