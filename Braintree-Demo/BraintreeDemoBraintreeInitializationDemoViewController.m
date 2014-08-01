#import "BraintreeDemoBraintreeInitializationDemoViewController.h"

#import <Braintree/Braintree.h>

#import "BraintreeDemoTransactionService.h"

@interface BraintreeDemoBraintreeInitializationDemoViewController ()
@property (nonatomic, copy) void (^completionBlock)(Braintree *braintree, NSString *merchantName, NSError *error);
@property (nonatomic, weak) IBOutlet UITextView *developerConsole;
@end

@implementation BraintreeDemoBraintreeInitializationDemoViewController

- (instancetype)initWithCompletion:(void (^)(Braintree *, NSString *, NSError *))completionBlock {
    self = [self init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}


#pragma mark UI Helpers

- (void)fireConsoleNotice:(NSString *)notice {
    NSString *timestamp = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle
                                                         timeStyle:NSDateFormatterLongStyle];
    self.developerConsole.text = [self.developerConsole.text stringByAppendingFormat:@"[%@] %@\n", timestamp, notice];
}

#pragma mark Demo Steps

- (void)initializeBraintree {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self fireConsoleNotice:@"Creating customer and fetching client token from merchant server"];
    [[BraintreeDemoTransactionService sharedService] createCustomerAndFetchClientTokenWithCompletion:^(NSString *clientToken, NSError *error){
        if (error) {
            [self fireConsoleNotice:[NSString stringWithFormat:@"Get request failed with error: %@", error]];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.completionBlock(nil, nil, error);
            return;
        }

        [self fireConsoleNotice:[NSString stringWithFormat:@"Successfully received client_token:\n%@…", [clientToken substringToIndex:70]]];

        [self fireConsoleNotice:@"Initializing Braintree"];
        Braintree *braintree = [Braintree braintreeWithClientToken:clientToken];
        [self fireConsoleNotice:[NSString stringWithFormat:@"Successfully initialized braintree: %@", braintree]];

        [self fireConsoleNotice:@"\nDONE!"];

        [[BraintreeDemoTransactionService sharedService] fetchMerchantConfigWithCompletion:^(NSString *merchantId, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (error) {
                [self fireConsoleNotice:[NSString stringWithFormat:@"Get request failed with error: %@", error]];
                self.completionBlock(nil, nil, error);
                return;
            }

            self.completionBlock(braintree, merchantId, nil);
        }];

        self.completionBlock(nil, nil, error);
    }];
}

#pragma mark View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self fireConsoleNotice:@"Preparing to initialize Braintree"];
    [self initializeBraintree];
}

@end
