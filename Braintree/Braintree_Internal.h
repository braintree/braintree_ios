#import "Braintree.h"
#import "BTPayPalButton.h"

// Private header for increasing testability.
@interface Braintree ()
@property (nonatomic, strong) BTPayPalButton *payPalButton;
@end
