#import "Braintree.h"
#import "BTPayPalControl.h"

// Private header for increasing testability.
@interface Braintree ()
@property (nonatomic, strong) BTPayPalControl *payPalControl;
@end
