#import "BraintreeDemoVenmoAppSwitchViewController.h"

#import "BTVenmoAppSwitchHandler.h"
//#import <NSURL+QueryDictionary/NSURL+QueryDictionary.h>

@interface BraintreeDemoVenmoAppSwitchViewController ()<BTAppSwitchingDelegate>
@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) void (^completionBlock)(NSString *nonce);
@property (nonatomic, copy) NSString *merchantID;

@property (nonatomic, weak) IBOutlet UITextView *statusTextView;

@end

@implementation BraintreeDemoVenmoAppSwitchViewController


- (instancetype)initWithBraintree:(Braintree *)braintree
                       merchantID:(NSString *)merchantID
                       completion:(void (^)(NSString *))completionBlock
{
    if (!merchantID) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Merchant ID is required (got %@)", merchantID]
                                     userInfo:nil];
    }

    self = [self init];
    if (self) {
        self.braintree = braintree;
        self.merchantID = merchantID;
        self.completionBlock = completionBlock;
    }
    return self;
}

- (IBAction)tappedToVenmoAppSwitch
{
    [BTVenmoAppSwitchHandler sharedHandler].returnURLScheme = @"com.braintreepayments.Braintree-Demo.payments";
    [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.braintree.client delegate:self];
}

- (void)appSwitcherWillSwitch:(id<BTAppSwitching>)switcher {
    NSLog(@"appSwitcherWillSwitch:%@", switcher);
}

- (void)appSwitcherWillCreatePaymentMethod:(id<BTAppSwitching>)switcher {
    NSLog(@"appSwitcherCreatePayment:%@", switcher);
}

- (void)appSwitcher:(id<BTAppSwitching>)switcher didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    NSLog(@"appSwitcher:%@", switcher);
    NSLog(@"payment: %@", paymentMethod);
}

- (void)appSwitcher:(id<BTAppSwitching>)switcher didFailWithError:(NSError *)error {
    NSLog(@"appSwitcher:%@", switcher);
    NSLog(@"error: %@", error);
}

- (void)appSwitcherDidCancel:(id<BTAppSwitching>)switcher {
    NSLog(@"appSwitcherDidCancel:%@", switcher);
}

@end
