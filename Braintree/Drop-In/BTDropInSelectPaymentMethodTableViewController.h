#import <UIKit/UIKit.h>
#import <Braintree/Braintree-API.h>

#import "BTUI.h"

@protocol BTDropInSelectPaymentMethodTableViewControllerDelegate;

/// Drop In's payment method selection flow.
@interface BTDropInSelectPaymentMethodTableViewController : UITableViewController

@property (nonatomic, strong) BTClient *client;
@property (nonatomic, weak) id<BTDropInSelectPaymentMethodTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *paymentMethods;
@property (nonatomic, assign) NSInteger selectedPaymentMethodIndex;

@property (nonatomic, strong) BTUI *theme;

@end

@protocol BTDropInSelectPaymentMethodTableViewControllerDelegate

- (void)dropInSelectPaymentMethodTableViewController:(BTDropInSelectPaymentMethodTableViewController *)viewController
                       didSelectPaymentMethodAtIndex:(NSUInteger)index;

- (void)dropInSelectPaymentMethodTableViewController:(BTDropInSelectPaymentMethodTableViewController *)viewController
                       didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;

- (void)dropInSelectPaymentMethodTableViewControllerDidCancel:(BTDropInSelectPaymentMethodTableViewController *)viewController;

@end