#import "BraintreeDemoVenmoAppSwitchViewController.h"

#import "BTVenmoAppSwitchHandler.h"
//#import <NSURL+QueryDictionary/NSURL+QueryDictionary.h>

@interface BraintreeDemoVenmoAppSwitchViewController ()<BTAppSwitchHandlerDelegate>
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

- (void)appSwitchHandlerWillAppSwitch:(id)appSwitchHandler {
    NSLog(@"appSwitchHandlerWillAppSwitch:%@", appSwitchHandler);
}

- (void)appSwitchHandlerWillCreatePaymentMethod:(id)appSwitchHandler {
    NSLog(@"appSwitchHandlerWillCreatePaymentMethod:%@", appSwitchHandler);
}

- (void)appSwitchHandler:(id)appSwitchHandler didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    NSLog(@"appSwitchHandler:%@ didCreatePaymentMethod:%@", appSwitchHandler, paymentMethod);
}

- (void)appSwitchHandler:(id)appSwitchHandler didFailWithError:(NSError *)error {
    NSLog(@"appSwitchHandler:%@ didFailWithError:%@", appSwitchHandler, error);
}

- (void)appSwitchHandlerDidCancel:(id)appSwitchHandler {
    NSLog(@"appSwitchHandlerDidCancel:%@", appSwitchHandler);
}

@end
