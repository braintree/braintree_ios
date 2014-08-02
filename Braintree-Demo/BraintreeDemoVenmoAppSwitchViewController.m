#import "BraintreeDemoVenmoAppSwitchViewController.h"

#import <NSURL+QueryDictionary/NSURL+QueryDictionary.h>

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
    NSDictionary *appSwitchParameters = @{
                                          @"x-success": @"com.braintreepayments.demo-app.v1://x-callback-url/vzero/auth/venmo/success",
                                          @"x-error": @"com.braintreepayments.demo-app.v1://x-callback-url/vzero/auth/venmo/error",
                                          @"x-cancel": @"com.braintreepayments.demo-app.v1://x-callback-url/vzero/auth/venmo/cancel",
                                          @"x-source": @"Braintree Demo",
                                          @"braintreeMerchantId": self.merchantID
                                          };

    NSURL *venmoAppSwitchURL = [[NSURL URLWithString:@"venmo://x-callback-url/vzero/auth"] uq_URLByAppendingQueryDictionary:appSwitchParameters];
    [[UIApplication sharedApplication] openURL:venmoAppSwitchURL];
}

@end
