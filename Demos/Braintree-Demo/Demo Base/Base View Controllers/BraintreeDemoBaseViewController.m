#import "BraintreeDemoBaseViewController.h"

@implementation BraintreeDemoBaseViewController

- (instancetype)initWithCoder:(__unused NSCoder *)aDecoder {
    return [self initWithClientKey:nil];
}

- (instancetype)initWithNibName:(__unused NSString *)nibNameOrNil bundle:(__unused NSBundle *)nibBundleOrNil {
    return [self initWithClientKey:nil];
}

- (instancetype)initWithClientToken:(__unused NSString *)clientToken {
    if ([self class] == [BraintreeDemoBaseViewController class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Subclasses must override initWithClientToken:" userInfo:nil];
    }

    return [super initWithNibName:nil bundle:nil];
}

- (instancetype)initWithClientKey:(__unused NSString *)clientKey {
    if ([self class] == [BraintreeDemoBaseViewController class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Subclasses must override initWithClientKey:" userInfo:nil];
    }

    return [super initWithNibName:nil bundle:nil];
}

@end
