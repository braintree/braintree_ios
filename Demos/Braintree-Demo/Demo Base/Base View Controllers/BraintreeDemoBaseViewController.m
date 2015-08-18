#import "BraintreeDemoBaseViewController.h"

@implementation BraintreeDemoBaseViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithClientKey:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithClientKey:nil];
}

- (instancetype)initWithClientToken:(__unused NSString *)clientToken {
    if ([self class] == [BraintreeDemoBaseViewController class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Subclasses must override initWithClientToken:" userInfo:nil];
    }

    return [super initWithCoder:[[NSCoder alloc] init]];
}

- (instancetype)initWithClientKey:(NSString *)clientKey {
    if ([self class] == [BraintreeDemoBaseViewController class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Subclasses must override initWithClientKey:" userInfo:nil];
    }

    return [super initWithCoder:[[NSCoder alloc] init]];
}

@end
