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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.title
                                           message:self.message
                                          delegate:self
                                 cancelButtonTitle:self.retryBlock ? @"Cancel" : @"OK"
                                 otherButtonTitles:nil];

    if (self.retryBlock) {
        [alertView addButtonWithTitle:@"Try Again"];
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
    return _title ?: @"Connection Error";
}

@end
