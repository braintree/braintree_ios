#import <UIKit/UIKit.h>
#import <BraintreeCore/BraintreeCore.h>
#import "BTUIThemedView.h"

@class BTClient, BTPaymentMethod;
@protocol BTPaymentMethodCreationDelegate;

@interface BTPaymentButton : BTUIThemedView

//- (instancetype)initWithPaymentProviderTypes:(NSOrderedSet *)paymentAuthorizationTypes;
- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (id)init;


- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient completion:(void(^)(id <BTTokenized> token, NSError *error))completion;
@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, copy) void(^completion)(id <BTTokenized> token, NSError *error);


/// Set of payment options as strings, e.g. `@"PayPal"`, `@"Venmo"`
@property (nonatomic, strong) NSOrderedSet *enabledPaymentOptions;

//@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

@property (nonatomic, readonly) BOOL hasAvailablePaymentMethod;

@end
