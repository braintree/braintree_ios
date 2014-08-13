
@class BTClient;
@class BTPayPalPaymentMethod;
@protocol BTPayPalAdapterDelegate;

@interface BTPayPalAdapter : NSObject

@property (nonatomic, strong) BTClient *client;

@property (nonatomic, weak) id<BTPayPalAdapterDelegate> delegate;

- (instancetype)initWithClient:(BTClient *)client;

- (void)initiatePayPalAuth;

@end

@protocol BTPayPalAdapterDelegate <NSObject>

#pragma mark Lifecycle Notifications

@optional

- (void)payPalAdapterWillCreatePayPalPaymentMethod:(BTPayPalAdapter *)payPalAdapter;

@required

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod;

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter didFailWithError:(NSError *)error;

- (void)payPalAdapterDidCancel:(BTPayPalAdapter *)payPalAdapter;

#pragma mark app switch based authentication

@optional

- (void)payPalAdapterWillAppSwitch:(BTPayPalAdapter *)payPalAdapter;

#pragma mark view controller based authentication

@required

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter requestsPresentationOfViewController:(UIViewController *)viewController;

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter requestsDismissalOfViewController:(UIViewController *)viewController;

@end
