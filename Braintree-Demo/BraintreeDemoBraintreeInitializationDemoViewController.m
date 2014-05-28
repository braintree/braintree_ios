#import "BraintreeDemoBraintreeInitializationDemoViewController.h"

#import <Braintree/Braintree.h>

#import "BraintreeDemoTransactionService.h"

@interface BraintreeDemoBraintreeInitializationDemoViewController ()
@property (nonatomic, copy) void (^completionBlock)(Braintree *braintree, NSError *error);
@property (nonatomic, weak) IBOutlet UITextView *developerConsole;
@end

@implementation BraintreeDemoBraintreeInitializationDemoViewController

- (instancetype)initWithCompletion:(void (^)(Braintree *, NSError *))completionBlock {
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
        if (clientToken) {
            [self fireConsoleNotice:[NSString stringWithFormat:@"Successfully received client_token:\n%@…", [clientToken substringToIndex:70]]];

            [self fireConsoleNotice:@"Initializing Braintree"];
            Braintree *braintree = [Braintree braintreeWithClientToken:clientToken];
            [self fireConsoleNotice:[NSString stringWithFormat:@"Successfully initialized braintree: %@", braintree]];

            [self fireConsoleNotice:@"\nDONE!"];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.completionBlock(braintree, nil);
        } else {
            [self fireConsoleNotice:[NSString stringWithFormat:@"Get request failed with error: %@", error]];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.completionBlock(nil, error);
        }
    }];
}

#pragma mark View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self fireConsoleNotice:@"Preparing to initialize Braintree"];
    [self initializeBraintree];
}

@end
