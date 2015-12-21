#import <UIKit/UIKit.h>

#import "BTDropInErrorAlert.h"
#import "BTDropInLocalizedString.h"
#import "BTUIUtil.h"

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
    NSString *localizedOK = BTDropInLocalizedString(ERROR_ALERT_OK_BUTTON_TEXT);
    NSString *localizedCancel = BTDropInLocalizedString(ERROR_ALERT_CANCEL_BUTTON_TEXT);
    
    if ([UIAlertController class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.title
                                                                       message:self.message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:self.retryBlock ? localizedCancel : localizedOK
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * __nonnull __unused action) {
                                                    if (self.cancelBlock) {
                                                        self.cancelBlock();
                                                    }
                                                }]];
        if (self.retryBlock) {
            NSString *localizedTryAgain = BTDropInLocalizedString(ERROR_ALERT_TRY_AGAIN_BUTTON_TEXT);
            [alert addAction:[UIAlertAction actionWithTitle:localizedTryAgain
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * __nonnull __unused action) {
                                                        if (self.retryBlock) {
                                                            self.retryBlock();
                                                        }
                                                    }]];
        }
        UIViewController *visibleViewController = [[UIApplication sharedApplication].delegate.window.rootViewController BTUI_visibleViewController];
        [visibleViewController presentViewController:alert animated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.title
                                                            message:self.message
                                                           delegate:self
                                                  cancelButtonTitle:self.retryBlock ? localizedCancel : localizedOK
                                                  otherButtonTitles:nil];
        if (self.retryBlock) {
            NSString *localizedTryAgain = BTDropInLocalizedString(ERROR_ALERT_TRY_AGAIN_BUTTON_TEXT);
            [alertView addButtonWithTitle:localizedTryAgain];
        }
        [alertView show];
#pragma clang diagnostic pop
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)alertView:(__unused UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
#pragma clang diagnostic pop
    if (buttonIndex == 0 && self.cancelBlock) {
        self.cancelBlock();
    } else if (buttonIndex == 1 && self.retryBlock) {
        self.retryBlock();
    }
}

- (NSString *)title {
    NSString *localizedConnectionError = BTDropInLocalizedString(ERROR_ALERT_CONNECTION_ERROR);
    
    return _title ?: localizedConnectionError;
}

@end
