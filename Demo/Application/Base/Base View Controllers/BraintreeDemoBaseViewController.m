#import "BraintreeDemoBaseViewController.h"

@implementation BraintreeDemoBaseViewController

- (instancetype)initWithCoder:(__unused NSCoder *)aDecoder {
    return [self initWithAuthorization:nil];
}

- (instancetype)initWithNibName:(__unused NSString *)nibNameOrNil bundle:(__unused NSBundle *)nibBundleOrNil {
    return [self initWithAuthorization:nil];
}

- (instancetype)initWithAuthorization:(__unused NSString *)authorization {
    if ([self class] == [BraintreeDemoBaseViewController class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Subclasses must override initWithAuthorization:" userInfo:nil];
    }

    return [super initWithNibName:nil bundle:nil];
}

- (void) viewDidLoad {
    UITapGestureRecognizer *tapToDismissKeyboard = [[UITapGestureRecognizer new] initWithTarget: self action: @selector(dismissKeyboard)];
    [self.view addGestureRecognizer: tapToDismissKeyboard];
}

-(void) dismissKeyboard {
    [self.view endEditing: YES];
}

@end
