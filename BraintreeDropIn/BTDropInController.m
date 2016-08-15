#import "BTDropInController.h"
#import "BTVaultManagementViewController.h"
#import "BTCardFormViewController.h"
#import "BTEnrollmentVerificationViewController.h"
#if __has_include("BraintreeCard.h")
#import "BTAPIClient_Internal.h"
#import "BraintreeCard.h"
#import "BraintreeUnionPay.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeUnionPay.h>
#endif

#define BT_ANIMATION_SLIDE_SPEED 0.35
#define BT_ANIMATION_TRANSITION_SPEED 0.1
#define BT_HALF_SHEET_HEIGHT 470
#define BT_HALF_SHEET_MARGIN 5
#define BT_HALF_SHEET_CORNER_RADIUS 12

@interface BTDropInController ()

@property (nonatomic, strong) BTConfiguration *configuration;
@property (nonatomic, strong, readwrite) BTAPIClient *apiClient;
@property (nonatomic, strong) UIToolbar *btToolbar;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *contentClippingView;
@property (nonatomic, strong) BTPaymentSelectionViewController *paymentSelectionViewController;
@property (nonatomic, strong) NSLayoutConstraint *contentHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentHeightConstraintBottom;
@property (nonatomic) BOOL useBlur;
@property (nonatomic, strong) UIVisualEffectView *blurredContentBackgroundView;
@property (nonatomic, copy, nullable) BTDropInControllerHandler handler;

@end

@implementation BTDropInController

#pragma mark - Prefetch BTDropInResult

+ (void)fetchDropInResultForAuthorization:(NSString *)authorization handler:(BTDropInControllerFetchHandler)handler {
    BTUIKPaymentOptionType lastSelectedPaymentOptionType = [[NSUserDefaults standardUserDefaults] integerForKey:@"BT_dropInLastSelectedPaymentMethodType"];
    __block BTAPIClient *apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
    apiClient = [apiClient copyWithSource:apiClient.metadata.source integration:BTClientMetadataIntegrationDropIn2];

    
    [apiClient fetchPaymentMethodNonces:NO completion:^(NSArray<BTPaymentMethodNonce *> *paymentMethodNonces, NSError *error) {
                                       if (error != nil) {
                                           handler(nil, error);
                                       } else {
                                           BTDropInResult *result = [BTDropInResult new];
                                           if (lastSelectedPaymentOptionType == BTUIKPaymentOptionTypeApplePay) {
                                               result.paymentOptionType = lastSelectedPaymentOptionType;
                                           } else if (paymentMethodNonces != nil && paymentMethodNonces.count > 0) {
                                               BTPaymentMethodNonce *paymentMethod = paymentMethodNonces.firstObject;
                                               result.paymentOptionType = [BTUIKViewUtil paymentOptionTypeForPaymentInfoType:paymentMethod.type];
                                               result.paymentMethod = paymentMethod;
                                           }
                                           handler(result, error);
                                       }
                                       apiClient = nil;
                                   }];
}

#pragma mark - Lifecycle

- (nullable instancetype)initWithAuthorization:(NSString *)authorization
                                       request:(BTDropInRequest *)request
                                       handler:(BTDropInControllerHandler) handler {
    if (self = [super init]) {
        BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:authorization];
        self.apiClient = [client copyWithSource:client.metadata.source integration:BTClientMetadataIntegrationDropIn2];

        _dropInRequest = [request copy];
        if (!_apiClient || !_dropInRequest) {
            return nil;
        }
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
            // Customize the iPad size...
            // self.preferredContentSize = CGSizeMake(600, 400);
        } else {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }
        
        self.useBlur = !UIAccessibilityIsReduceTransparencyEnabled();
        if (![BTUIKAppearance sharedInstance].useBlurs) {
            self.useBlur = NO;
        }
        self.handler = handler;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpViews];
    [self setUpChildViewControllers];
    [self setUpConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isBeingPresented) {
        [self.paymentSelectionViewController loadConfiguration];
        
        [self resetDropInState];
        [self loadConfiguration];
        if ([self isFormSheet]) {
            // Position the views in screen before appearing
            [self flexViewAnimated:NO];
        } else {
            // Move content off screen so it can be animated in when it appears
            CGFloat sh = CGRectGetHeight([[UIScreen mainScreen] bounds]) + [UIApplication sharedApplication].statusBarFrame.size.height;
            self.contentHeightConstraintBottom.constant = sh;
            self.contentHeightConstraint.constant = sh;
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
            [self flexViewAnimated:YES];
        }
    } else {
        [self flexViewAnimated:NO];
        [self.view setNeedsDisplay];
    }
    [self.apiClient sendAnalyticsEvent:@"ios.dropin2.appear"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.apiClient sendAnalyticsEvent:@"ios.dropin2.disappear"];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    // before rotating
    [coordinator animateAlongsideTransition:^(__unused id<UIViewControllerTransitionCoordinatorContext> context) {
        // while rotating
        if (self.view.window != nil && !self.isBeingDismissed) {
            [self flexViewAnimated:NO];
            [self.view setNeedsDisplay];
            [self.view setNeedsLayout];
        }
    } completion:^(__unused id<UIViewControllerTransitionCoordinatorContext> context) {
        // after rotating
    }];
}

#pragma mark - Setup

- (void)setUpViews {
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[BTDropInController.self]] setTitleTextAttributes:@{NSForegroundColorAttributeName: [BTUIKAppearance sharedInstance].tintColor, NSFontAttributeName:[UIFont fontWithName:[BTUIKAppearance sharedInstance].fontFamily size:[UIFont labelFontSize]]} forState:UIControlStateNormal];
    if ([BTUIKAppearance sharedInstance].tintColor != nil) {
        self.view.tintColor = [BTUIKAppearance sharedInstance].tintColor;
    }
    self.view.opaque = NO;
    self.view.backgroundColor = [BTUIKAppearance sharedInstance].overlayColor;
    self.view.userInteractionEnabled = YES;
    
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = self.useBlur ? [UIColor clearColor] : [BTUIKAppearance sharedInstance].formBackgroundColor;
    self.contentView.layer.cornerRadius = BT_HALF_SHEET_CORNER_RADIUS;
    self.contentView.clipsToBounds = true;

    [self.view addSubview: self.contentView];
    
    self.contentClippingView = [[UIView alloc] init];
    self.contentClippingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview: self.contentClippingView];
    self.contentClippingView.backgroundColor = [UIColor clearColor];
    self.contentClippingView.clipsToBounds = true;
    
    self.btToolbar = [[UIToolbar alloc] init];
    self.btToolbar.delegate = self;
    self.btToolbar.userInteractionEnabled = YES;
    self.btToolbar.barStyle = UIBarStyleDefault;
    self.btToolbar.translucent = YES;
    self.btToolbar.backgroundColor = [UIColor clearColor];
    [self.btToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.btToolbar.barTintColor = [UIColor clearColor];
    self.btToolbar.translatesAutoresizingMaskIntoConstraints = false;
    [self.contentView addSubview:self.btToolbar];
    
    UIBlurEffect *contentEffect = [UIBlurEffect effectWithStyle:[BTUIKAppearance sharedInstance].blurStyle];
    self.blurredContentBackgroundView = [[UIVisualEffectView alloc] initWithEffect:contentEffect];
    self.blurredContentBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    self.blurredContentBackgroundView.hidden = !self.useBlur;
    [self.contentView addSubview:self.blurredContentBackgroundView];
    [self.contentView sendSubviewToBack:self.blurredContentBackgroundView];
    
}

- (void)setUpChildViewControllers {
    self.paymentSelectionViewController = [[BTPaymentSelectionViewController alloc] initWithAPIClient:self.apiClient request:self.dropInRequest];
    self.paymentSelectionViewController.delegate = self;
    [self.contentClippingView addSubview:self.paymentSelectionViewController.view];
    self.paymentSelectionViewController.view.hidden = YES;
    self.paymentSelectionViewController.navigationItem.leftBarButtonItem.target = self;
    self.paymentSelectionViewController.navigationItem.leftBarButtonItem.action = @selector(cancelHit:);
}

- (void)setUpConstraints {
    NSDictionary *viewBindings = @{
                                   @"view": self,
                                   @"toolbar": self.btToolbar,
                                   @"contentView": self.contentView,
                                   @"contentClippingView":self.contentClippingView,
                                   @"paymentSelectionViewController":self.paymentSelectionViewController.view
                                   };
    
    NSDictionary *metrics = @{@"BT_HALF_SHEET_MARGIN":@([self sheetInset])};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(BT_HALF_SHEET_MARGIN)-[contentView]-(BT_HALF_SHEET_MARGIN)-|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:viewBindings]];
    
    
    self.contentHeightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    [self.view addConstraint:self.contentHeightConstraint];
    
    self.contentHeightConstraintBottom = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraint:self.contentHeightConstraintBottom];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[paymentSelectionViewController]|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[paymentSelectionViewController]|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:viewBindings]];
    
    [self.blurredContentBackgroundView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
    [self.blurredContentBackgroundView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    [self.blurredContentBackgroundView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.blurredContentBackgroundView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
    
    [self applyContentViewConstraints];
}

- (void)loadConfiguration {
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.configuration = configuration;
            if (!error) {
                self.paymentSelectionViewController.view.hidden = NO;
                self.paymentSelectionViewController.view.alpha = 1.0;
                [self updateToolbarForViewController:self.paymentSelectionViewController];
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:error.localizedDescription ?: @"Connection Error" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __unused _Nonnull action) {
                    if (self.handler) {
                        self.handler(self, nil, error);
                    }
                }];
                [alertController addAction: alertAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        });
    }];
}

#pragma mark - View management and actions

- (void)cancelHit:(__unused id)sender {
    BTDropInResult *result = [[BTDropInResult alloc] init];
    result.cancelled = YES;
    if (self.handler) {
        self.handler(self, result, nil);
    }
}

- (void)cardTokenizationCompleted:(BTPaymentMethodNonce *)tokenizedCard error:(NSError *)error sender:(BTCardFormViewController *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.handler) {
            BTDropInResult *result = [[BTDropInResult alloc] init];
            if (tokenizedCard != nil) {
                result.paymentOptionType = [BTUIKViewUtil paymentOptionTypeForPaymentInfoType:tokenizedCard.type];
                result.paymentMethod = tokenizedCard;
            }
            [sender dismissViewControllerAnimated:YES completion:^{
                self.handler(self, result, error);
            }];
        }
    });
}

- (void)updateToolbarForViewController:(UIViewController*)viewController {
    UILabel *titleLabel = [[UILabel alloc] init];
    [BTUIKAppearance styleLabelBoldPrimary:titleLabel];
    titleLabel.text = viewController.title ? viewController.title : @"";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    UIBarButtonItem *barTitle = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *leftItem = viewController.navigationItem.leftBarButtonItem ? viewController.navigationItem.leftBarButtonItem : fixed;
    UIBarButtonItem *rightItem = viewController.navigationItem.rightBarButtonItem ? viewController.navigationItem.rightBarButtonItem : fixed;
    [self.btToolbar setItems:@[leftItem, flex, barTitle, flex, rightItem] animated:YES];
}

- (void)showCardForm:(__unused id)sender {
    BTCardFormViewController* vd = [[BTCardFormViewController alloc] initWithAPIClient:self.apiClient request:self.dropInRequest];
    vd.delegate = self;
      UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:vd];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        navController.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UI Helpers

- (float)sheetInset {
    return [self isFormSheet] ? 0 : BT_HALF_SHEET_MARGIN;
}

- (BOOL)isFullScreen {
    return ![self supportsHalfSheet] || [self isFormSheet] ;
}

- (void)flexViewAnimated:(BOOL)animated{
    [self.btToolbar removeFromSuperview];
    [self.contentView addSubview:self.btToolbar];
    
    if ([self isFormSheet]) {
        // iPad formSheet
        self.contentHeightConstraint.constant = 0;
    } else {
        // Flexible views
        int statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        int sh = [[UIScreen mainScreen] bounds].size.height;
        int sheetHeight = BT_HALF_SHEET_HEIGHT;
        self.contentHeightConstraint.constant = self.isFullScreen ? statusBarHeight + [self sheetInset] : (sh - sheetHeight - [self sheetInset]);
    }
    
    [self applyContentViewConstraints];
    
    [self.view setNeedsUpdateConstraints];

    self.contentHeightConstraintBottom.constant = -[self sheetInset];

    if (animated) {
        [UIView animateWithDuration:BT_ANIMATION_SLIDE_SPEED delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:4 options:0 animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }
}

- (void)applyContentViewConstraints {
    NSDictionary *viewBindings = @{@"toolbar": self.btToolbar,
                                   @"contentClippingView": self.contentClippingView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentClippingView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[toolbar][contentClippingView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewBindings]];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // No iPad specific dismissal animation
    } else {
        CGFloat sh = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        self.contentHeightConstraintBottom.constant = sh;
        self.contentHeightConstraint.constant = sh;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:BT_ANIMATION_SLIDE_SPEED animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    [super dismissViewControllerAnimated:flag completion:completion];
}

- (void)resetDropInState {
    self.configuration = nil;
    self.paymentSelectionViewController.view.hidden = NO;
    self.paymentSelectionViewController.view.alpha = 1.0;
}

// No fullscreen when in landscape or FormSheet modes.
- (BOOL)supportsHalfSheet {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight || [self isFormSheet]) {
        return false;
    }
    return true;
}

- (BOOL)isFormSheet {
    return self.modalPresentationStyle == UIModalPresentationFormSheet;
}

#pragma mark - UI Preferences

- (BOOL)prefersStatusBarHidden {
    if (self.presentingViewController != nil) {
        return [self.presentingViewController prefersStatusBarHidden];
    }
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.presentingViewController != nil) {
        return [self.presentingViewController preferredStatusBarStyle];
    }
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    if (bar == self.btToolbar && self.isFullScreen && ![self isFormSheet]) {
        return UIBarPositionTopAttached;
    }
    return UIBarPositionTop;
}

#pragma mark BTAppSwitchDelegate

- (void)appSwitcherWillPerformAppSwitch:(__unused id)appSwitcher {
    // No action
}

- (void)appSwitcherWillProcessPaymentInfo:(__unused id)appSwitcher {
    // No action
}

- (void)appSwitcher:(__unused id)appSwitcher didPerformSwitchToTarget:(__unused BTAppSwitchTarget)target {
    // No action
}

- (void)paymentDriver:(__unused id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    // Needed for iPad
    viewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(__unused id)driver requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectionCompletedWithPaymentMethodType:(BTUIKPaymentOptionType)type nonce:(BTPaymentMethodNonce *)nonce error:(NSError *)error {
    if (error == nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:type forKey:@"BT_dropInLastSelectedPaymentMethodType"];
        if (self.handler != nil) {
            BTDropInResult *result = [BTDropInResult new];
            result.paymentOptionType = type;
            result.paymentMethod = nonce;
            self.handler(self, result, error);
        }
    }
}

@end
