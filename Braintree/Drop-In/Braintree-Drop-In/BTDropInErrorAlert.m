#import "BTDropInErrorAlert.h"

@interface BTDropInErrorAlert () <UIAlertViewDelegate>

@property (nonatomic, copy) void (^retryBlock)(void);

@property (nonatomic, copy) void (^cancelBlock)(void);

@end

@implementation BTDropInErrorAlert

- (instancetype)initWithCancel:(void (^)(void))cancelBlock retry:(void (^)(void))retryBlock {
    self = [super init];
    if (self) {
        self.retryBlock = retryBlock;
        self.cancelBlock = cancelBlock;
    }
    return self;
}


- (void)show {
    NSString *localizedOK = NSLocalizedStringWithDefaultValue(@"ERROR_ALERT_OK_BUTTON_TEXT", @"DropIn", [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Braintree-Drop-In-Localization" ofType:@"bundle"]], @"OK", @"Button text to indicate acceptance of an alert condition");
    NSString *localizedCancel = NSLocalizedStringWithDefaultValue(@"ERROR_ALERT_CANCEL_BUTTON_TEXT", @"DropIn", [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Braintree-Drop-In-Localization" ofType:@"bundle"]], @"Cancel", @"Button text to indicate acceptance of an alert condition");

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.title
                                                        message:self.message
                                                       delegate:self
                                              cancelButtonTitle:self.retryBlock ? localizedCancel : localizedOK
                                 otherButtonTitles:nil];

    if (self.retryBlock) {
        NSString *localizedTryAgain = NSLocalizedStringWithDefaultValue(@"ERROR_ALERT_TRY_AGAIN_BUTTON_TEXT", @"DropIn", [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Braintree-Drop-In-Localization" ofType:@"bundle"]], @"Try Again", @"Button text to request that an failed operation should be restarted and to try again");
        [alertView addButtonWithTitle:localizedTryAgain];

    }

    [alertView show];
}

- (void)alertView:(__unused UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 && self.cancelBlock) {
        self.cancelBlock();
    } else if (buttonIndex == 1 && self.retryBlock) {
        self.retryBlock();
    }
}

- (NSString *)title {
    NSString *localizedConnectionError = NSLocalizedStringWithDefaultValue(@"ERROR_ALERT_CONNECTION_ERROR", @"DropIn", [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Braintree-Drop-In-Localization" ofType:@"bundle"]], @"Connection Error", @"Vague title for alert view that ambiguously indicates an unspecified failure");

    return _title ?: localizedConnectionError;
}

@end
