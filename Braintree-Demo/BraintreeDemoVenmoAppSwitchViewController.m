#import "BraintreeDemoVenmoAppSwitchViewController.h"

#import "BTVenmoAppSwitchHandler.h"
//#import <NSURL+QueryDictionary/NSURL+QueryDictionary.h>

@interface BraintreeDemoVenmoAppSwitchViewController ()
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
    [BTVenmoAppSwitchHandler sharedHandler].callbackURLScheme = @"com.braintreepayments.Braintree-Demo.payments";
    [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.braintree.client delegate:self];
}

@end
