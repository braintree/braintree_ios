#import "BTPayPalViewController.h"
#import "PayPalMobile.h"

@interface BTPayPalViewController () <PayPalProfileSharingDelegate>
@property (nonatomic, readwrite, strong) PayPalProfileSharingViewController *payPalProfileSharingViewController;
@end
