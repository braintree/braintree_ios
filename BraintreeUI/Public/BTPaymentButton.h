#import "BTUIThemedView.h"
#import <UIKit/UIKit.h>

@protocol BTAppSwitchDelegate, BTViewControllerPresentingDelegate;
@class BTAPIClient, BTPaymentMethodNonce;

@interface BTPaymentButton : BTUIThemedView

//- (instancetype)initWithPaymentProviderTypes:(NSOrderedSet *)paymentAuthorizationTypes;
- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)init;


- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient completion:(void(^)(BTPaymentMethodNonce *tokenization, NSError *error))completion;

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

@property (nonatomic, strong) BTAPIClient *apiClient;

@property (nonatomic, copy) void(^completion)(BTPaymentMethodNonce *tokenization, NSError *error);


/// Set of payment options as strings, e.g. `@"PayPal"`, `@"Venmo"`. By default, this is configured
/// to the set of payment options that have been included in the client-side app integration.
///
/// Setting this property will force the button to reload.
@property (nonatomic, strong) NSOrderedSet *enabledPaymentOptions;

@property (nonatomic, weak) id <BTAppSwitchDelegate> appSwitchDelegate;
@property (nonatomic, weak) id <BTViewControllerPresentingDelegate> viewControllerPresentingDelegate;

@property (nonatomic, readonly) BOOL hasAvailablePaymentMethod;

@end
