#import <UIKit/UIKit.h>

#import "BraintreeCore.h"

#import "BTUI.h"

@protocol BTDropInSelectPaymentMethodViewControllerDelegate;

/// Drop In's payment method selection flow.
@interface BTDropInSelectPaymentMethodViewController : UITableViewController

//@property (nonatomic, strong) BTClient *client;
@property (nonatomic, strong) BTAPIClient *client;
@property (nonatomic, weak) id<BTDropInSelectPaymentMethodViewControllerDelegate> delegate;

// Array of id <BTTokenized> objects
@property (nonatomic, strong) NSArray *paymentInfoObjects;

@property (nonatomic, assign) NSInteger selectedPaymentMethodIndex;

@property (nonatomic, strong) BTUI *theme;

@end

@protocol BTDropInSelectPaymentMethodViewControllerDelegate

- (void)selectPaymentMethodViewController:(BTDropInSelectPaymentMethodViewController *)viewController
            didSelectPaymentMethodAtIndex:(NSUInteger)index;

- (void)selectPaymentMethodViewControllerDidRequestNew:(BTDropInSelectPaymentMethodViewController *)viewController;

@end
