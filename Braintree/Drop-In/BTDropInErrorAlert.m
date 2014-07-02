#import "BTDropInErrorAlert.h"

@interface BTDropInErrorAlert () <UIAlertViewDelegate>

@property (nonatomic, strong) NSError *error;

@property (nonatomic, copy) void (^retryBlock)(void);

@property (nonatomic, copy) void (^cancelBlock)(NSError *error);

@end

@implementation BTDropInErrorAlert

- (instancetype) initWithError:(NSError *)error cancel:(void (^)(NSError *error))cancelBlock retry:(void (^)(void))retryBlock{
    self = [super init];
    if (self){
        self.error = error;
        self.retryBlock = retryBlock;
        self.cancelBlock = cancelBlock;
    }
    return self;
}


- (void)show{
    [[[UIAlertView alloc] initWithTitle:self.title
                                message:nil
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Try Again", nil] show];
}

- (void)alertView:(__unused UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && self.cancelBlock) {
        self.cancelBlock(self.error);
    } else if (buttonIndex == 1 && self.retryBlock) {
        self.retryBlock();
    }
}

- (NSString *)title{
    return _title ?: @"Connection Error";
}

@end
