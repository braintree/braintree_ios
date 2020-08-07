#import "BTDropInErrorAlert.h"
#import "BTDropInLocalizedString.h"

@interface BTDropInErrorAlert ()

@property (nonatomic, copy, nullable) void (^dismissalHandler)(void);

@end

@implementation BTDropInErrorAlert

- (instancetype)initWithPresentingViewController:(UIViewController *)viewController
{
    if (self = [super init]) {
        _presentingViewController = viewController;
    }
    return self;
}


- (void)showWithDismissalHandler:(void (^)(void))dismissalHandler {
    NSString *localizedOK = BTDropInLocalizedString(ERROR_ALERT_OK_BUTTON_TEXT);
    NSString *localizedCancel = BTDropInLocalizedString(ERROR_ALERT_CANCEL_BUTTON_TEXT);
    self.dismissalHandler = dismissalHandler;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title
                                                                             message:self.message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:self.retryBlock ? localizedCancel : localizedOK
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(__unused UIAlertAction *action) {
                                                          if (self.cancelBlock) {
                                                              self.cancelBlock();
                                                          }
                                                          if (self.dismissalHandler) {
                                                              self.dismissalHandler();
                                                          }
                                                      }]];
    if (self.retryBlock) {
        [alertController addAction:[UIAlertAction actionWithTitle:BTDropInLocalizedString(ERROR_ALERT_TRY_AGAIN_BUTTON_TEXT)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(__unused UIAlertAction *action) {
                                                              if (self.retryBlock) {
                                                                  self.retryBlock();
                                                              }
                                                              if (self.dismissalHandler) {
                                                                  self.dismissalHandler();
                                                              }
                                                          }]];
    }
    
    [self.presentingViewController presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)title {
    return _title ?: BTDropInLocalizedString(ERROR_ALERT_CONNECTION_ERROR);
}

@end
