#import "BraintreeDemoBaseViewController.h"

@implementation BraintreeDemoBaseViewController

- (instancetype)initWithClientToken:(__unused NSString *)clientToken {
    if ([self class] == [BraintreeDemoBaseViewController class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Subclasses must override initWithClientToken:" userInfo:nil];
    }

    return [super initWithNibName:nil bundle:nil];
}

- (nonnull instancetype)initWithNibName:(nullable __unused NSString *)nibNameOrNil bundle:(nullable __unused NSBundle *)nibBundleOrNil {
    return [self initWithClientToken:nil];
}

- (instancetype)initWithCoder:(nonnull __unused NSCoder *)aDecoder {
    return [self initWithClientToken:nil];
}

@end
