#import <UIKit/UIKit.h>
#import <BraintreeCore/BraintreeCore.h>
#import "BTUIThemedView.h"

@class BTClient, BTPaymentMethod;
@protocol BTPaymentDriverDelegate;

@interface BTPaymentButton : BTUIThemedView

//- (instancetype)initWithPaymentProviderTypes:(NSOrderedSet *)paymentAuthorizationTypes;
- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)init;


- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient completion:(void(^)(id <BTTokenized> tokenization, NSError *error))completion;
@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, copy) void(^completion)(id <BTTokenized> token, NSError *error);


/// Set of payment options as strings, e.g. `@"PayPal"`, `@"Venmo"`. By default, this is configured
/// to the set of payment options that have been included in the client-side app integration.
///
/// Setting this property will force the button to reload.
@property (nonatomic, strong) NSOrderedSet *enabledPaymentOptions;

@property (nonatomic, weak) id<BTPaymentDriverDelegate> delegate;

@property (nonatomic, readonly) BOOL hasAvailablePaymentMethod;

@end
