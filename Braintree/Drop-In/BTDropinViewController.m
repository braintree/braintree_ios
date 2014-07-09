#import "BTDropInViewController.h"
#import "BTDropInContentView.h"
#import "BTDropInSelectPaymentMethodViewController.h"
#import "BTUICardFormView.h"
#import "BTUIScrollView.h"
#import "BTDropInUtil.h"
#import "Braintree-API.h"
#import "BTClient+BTPayPal.h"
#import "BTDropInErrorState.h"
#import "BTDropInErrorAlert.h"

@interface BTDropInViewController () < BTDropInSelectPaymentMethodViewControllerDelegate, BTUIScrollViewScrollRectToVisibleDelegate, BTUICardFormViewDelegate, BTPayPalButtonViewControllerPresenterDelegate, BTPayPalButtonDelegate, BTDropInViewControllerDelegate>

@property (nonatomic, strong) BTDropInContentView *dropInContentView;
@property (nonatomic, strong) BTUIScrollView *scrollView;
@property (nonatomic, assign) NSInteger selectedPaymentMethodIndex;
@property (nonatomic, strong) UIBarButtonItem *submitBarButtonItem;

/// Whether current visible.
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) NSTimeInterval visibleStartTime;

/// If YES, fetch and display payment methods on file, summary view, CTA control.
/// If NO, do not fetch payment methods, and just show UI to add a new method.
///
/// Defaults to `YES`.
@property (nonatomic, assign) BOOL fullForm;

/// Strong reference to an additional BTPayPalButton. Reference is needed so
/// activity can continue after dismissal
@property (nonatomic, strong) BTPayPalButton *retainedPayPalButton;

/// Strong reference to a BTDropInErrorAlert. Reference is needed to
/// handle user input from UIAlertView.
@property (nonatomic, strong) BTDropInErrorAlert *fetchPaymentMethodsErrorAlert;

/// Strong reference to  BTDropInErrorAlert. Reference is needed to
/// handle user input from UIAlertView.
@property (nonatomic, strong) BTDropInErrorAlert *savePayPalAccountErrorAlert;

@end

@implementation BTDropInViewController

- (instancetype)initWithClient:(BTClient *)client {
    self = [self init];
    if (self) {
        self.theme = [BTUI braintreeTheme];
        self.client = client;
        self.dropInContentView = [[BTDropInContentView alloc] init];
        self.dropInContentView.payPalButton.client = self.client;
        self.dropInContentView.payPalButton.presentationDelegate = self;
        self.dropInContentView.payPalButton.delegate = self;
        self.dropInContentView.hidePayPal =  !self.client.btPayPal_isPayPalEnabled;
        self.selectedPaymentMethodIndex = NSNotFound;
        self.dropInContentView.state = BTDropInContentViewStateActivity;
        self.fullForm = YES;
        _callToActionText = @"Pay";
    }
    return self;
}

- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.view.backgroundColor = self.theme.viewBackgroundColor;

    // Configure Subviews
    self.scrollView = [[BTUIScrollView alloc] init];
    self.scrollView.scrollRectToVisibleDelegate = self;
    self.scrollView.bounces = YES;
    self.scrollView.scrollsToTop = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    self.dropInContentView.translatesAutoresizingMaskIntoConstraints = NO;

    self.dropInContentView.cardForm.delegate = self;
    self.dropInContentView.cardForm.alphaNumericPostalCode = YES;
    self.dropInContentView.cardForm.optionalFields = self.optionalFieldsFromClientToken;

    [self.dropInContentView.changeSelectedPaymentMethodButton addTarget:self
                                                                 action:@selector(tappedChangePaymentMethod)
                                                       forControlEvents:UIControlEventTouchUpInside];

    [self.dropInContentView.ctaControl addTarget:self
                                          action:@selector(tappedSubmitForm)
                                forControlEvents:UIControlEventTouchUpInside];

    self.dropInContentView.cardFormSectionHeader.textColor = self.theme.sectionHeaderTextColor;
    self.dropInContentView.cardFormSectionHeader.font = self.theme.sectionHeaderFont;
    self.dropInContentView.cardFormSectionHeader.text = @"Pay with a card";

     // Call the setters explicitly
    [self setCallToActionText:_callToActionText];
    [self setSummaryDescription:_summaryDescription];
    [self setSummaryTitle:_summaryTitle];
    [self setDisplayAmount:_displayAmount];
    [self setShouldHideCallToAction:_shouldHideCallToAction];

    [self.dropInContentView setNeedsUpdateConstraints];

    // Add Subviews
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.dropInContentView];

    // Add initial constraints
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"scrollView": self.scrollView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"scrollView": self.scrollView}]];

    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.dropInContentView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.scrollView
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1
                                                                 constant:0]];

    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dropInContentView]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:@{@"dropInContentView": self.dropInContentView}]];

    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dropInContentView]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:@{@"dropInContentView": self.dropInContentView}]];

    if (!self.fullForm) {
        self.dropInContentView.state = BTDropInContentViewStateForm;
    }

    [self updateValidity];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.visible = YES;
    self.visibleStartTime = [NSDate timeIntervalSinceReferenceDate];

    // Ensure dropInContentView is visible. See viewWillDisappear below
    self.dropInContentView.alpha = 1.0f;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Quickly fade out the content view to prevent a jarring effect
    // as keyboard dimisses.
    [UIView animateWithDuration:self.theme.quickTransitionDuration animations:^{
        self.dropInContentView.alpha = 0.0f;
    }];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.visible = NO;
}

#pragma mark - BTUIScrollViewScrollRectToVisibleDelegate implementation

// Delegate implementation to handle "custom" autoscrolling via the BTUIScrollView class
//
// Scroll priorities are:
// 1. Attempt to display the submit button, even if it means the card form title is not visible.
// 2. If that isn't possible, at least attempt to show the card form title.
// 3. If that fails, fail just do the default behavior (relevant in landscape).
//
// Some cleanup here could attempt to parameterize or make sane some of the magic number pixel nudging.
- (void)scrollView:(BTUIScrollView *)scrollView requestsScrollRectToVisible:(CGRect)rect animated:(BOOL)animated {

    CGRect targetRect = rect;

    CGRect desiredVisibleTopRect = [self.scrollView convertRect:self.dropInContentView.cardFormSectionHeader.frame fromView:self.dropInContentView];
    desiredVisibleTopRect.origin.y -= 7;
    CGRect desiredVisibleBottomRect;
    if (self.dropInContentView.ctaControl.hidden) {
        desiredVisibleBottomRect = desiredVisibleTopRect;
    } else {
        desiredVisibleBottomRect = [self.scrollView convertRect:self.dropInContentView.ctaControl.frame fromView:self.dropInContentView];
    }

    CGFloat visibleAreaHeight = self.scrollView.frame.size.height - self.scrollView.contentInset.bottom - self.scrollView.contentInset.top;

    CGRect weightedBottomRect = CGRectUnion(targetRect, desiredVisibleBottomRect);
    if (weightedBottomRect.size.height <= visibleAreaHeight) {
        targetRect = weightedBottomRect;
    }

    CGRect weightedTopRect = CGRectUnion(targetRect, desiredVisibleTopRect);

    if (weightedTopRect.size.height <= visibleAreaHeight) {
        targetRect = weightedTopRect;
        targetRect.size.height = MIN(visibleAreaHeight, CGRectGetMaxY(weightedBottomRect) - CGRectGetMinY(targetRect));
    }

    [scrollView defaultScrollRectToVisible:targetRect animated:animated];
}

#pragma mark - Keyboard behavior

- (void)keyboardWillHide:(__unused NSNotification *)inputViewNotification {
    UIEdgeInsets ei = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    [UIView animateWithDuration:self.theme.transitionDuration animations:^{
        self.scrollView.scrollIndicatorInsets = ei;
        self.scrollView.contentInset = ei;
    }];
}

- (void)keyboardWillShow:(__unused NSNotification *)inputViewNotification {
    CGRect inputViewFrame = [[[inputViewNotification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect inputViewFrameInView = [self.view convertRect:inputViewFrame fromView:nil];
    CGRect intersection = CGRectIntersection(self.scrollView.frame, inputViewFrameInView);
    UIEdgeInsets ei = UIEdgeInsetsMake(0.0, 0.0, intersection.size.height, 0.0);
    self.scrollView.scrollIndicatorInsets = ei;
    self.scrollView.contentInset = ei;
}

#pragma mark - Handlers

- (void)tappedChangePaymentMethod {
    UIViewController *rootViewController;
    if (self.paymentMethods.count == 1) {
        rootViewController = [self addPaymentMethodDropInViewController];
    } else {
        BTDropInSelectPaymentMethodViewController *selectPaymentMethod = [[BTDropInSelectPaymentMethodViewController alloc] init];
        selectPaymentMethod.title = @"Payment Method";
        selectPaymentMethod.theme = self.theme;
        selectPaymentMethod.paymentMethods = self.paymentMethods;
        selectPaymentMethod.selectedPaymentMethodIndex = self.selectedPaymentMethodIndex;
        selectPaymentMethod.delegate = self;
        selectPaymentMethod.client = self.client;
        rootViewController = selectPaymentMethod;
    }
    rootViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                        target:self
                                                                                                        action:@selector(didCancelChangePaymentMethod)];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)tappedSubmitForm {
    [self showLoadingState:YES];

    BTPaymentMethod *paymentMethod = [self selectedPaymentMethod];
    if (paymentMethod != nil) {
        [self informDelegateWillComplete];
        [self informDelegateDidAddPaymentMethod:paymentMethod];
    } else if (!self.dropInContentView.cardForm.hidden) {
        BTUICardFormView *cardForm = self.dropInContentView.cardForm;

        void (^cardFail)(NSError *) = ^(NSError *error) {
            [self showLoadingState:NO];

            if (error && [error.domain isEqualToString:BTBraintreeAPIErrorDomain] && error.code == BTCustomerInputErrorInvalid) {
                [self informUserDidFailWithError:error];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error Saving Card"
                                            message:@"Please try again."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        };

        if (cardForm.valid) {
            [self informDelegateWillComplete];
            [self.client saveCardWithNumber:cardForm.number
                            expirationMonth:cardForm.expirationMonth
                             expirationYear:cardForm.expirationYear
                                        cvv:cardForm.cvv
                                 postalCode:cardForm.postalCode
                                   validate:YES
                                    success:^(BTCardPaymentMethod *card) {
                                        [self showLoadingState:NO];
                                        [self informDelegateDidAddPaymentMethod:card];
                                    }
                                    failure:cardFail];
        } else {
            cardFail(nil);
        }
    }
}

- (void)didCancelChangePaymentMethod {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Progress UI

- (void)showLoadingState:(BOOL)loadingState {
    [self.dropInContentView.ctaControl showLoadingState:loadingState];
    self.submitBarButtonItem.enabled = !loadingState;
    if (self.submitBarButtonItem != nil) {
        [BTUI activityIndicatorViewStyleForBarTintColor:self.navigationController.navigationBar.barTintColor];
        UIActivityIndicatorView *submitInProgressActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [submitInProgressActivityIndicator startAnimating];
        UIBarButtonItem *submitInProgressActivityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:submitInProgressActivityIndicator];
        [self.navigationItem setRightBarButtonItem:(loadingState ? submitInProgressActivityIndicatorBarButtonItem : self.submitBarButtonItem) animated:YES];
    }
}

#pragma mark Error UI

- (void)informUserDidFailWithError:(__unused NSError *)error {
    BTDropInErrorState *state = [[BTDropInErrorState alloc] initWithError:error];

    [self.dropInContentView.cardForm showTopLevelError:state.errorTitle];
    for (NSNumber *fieldNumber in state.highlightedFields) {
        BTUICardFormField field = [fieldNumber unsignedIntegerValue];
        [self.dropInContentView.cardForm showErrorForField:field];
    }
}

#pragma mark Card Form Delegate methods

- (void)cardFormViewDidChange:(__unused BTUICardFormView *)cardFormView {
    [self updateValidity];
}

#pragma mark Drop In Select Payment Method Table View Controller Delegate methods

- (void)selectPaymentMethodViewController:(BTDropInSelectPaymentMethodViewController *)viewController
            didSelectPaymentMethodAtIndex:(NSUInteger)index {
    self.selectedPaymentMethodIndex = index;
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectPaymentMethodViewControllerDidRequestNew:(BTDropInSelectPaymentMethodViewController *)viewController {
    [viewController.navigationController pushViewController:[self addPaymentMethodDropInViewController] animated:YES];
}

#pragma mark BTDropInViewControllerDelegate implementation

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];

    NSMutableArray *newPaymentMethods = [NSMutableArray arrayWithArray:self.paymentMethods];
    [newPaymentMethods insertObject:paymentMethod atIndex:0];
    self.paymentMethods = newPaymentMethods;
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController {
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PayPal Button Presentation Delegate methods

- (void)payPalButton:(BTPayPalButton *)button requestsPresentationOfViewController:(UIViewController *)viewController {
    if (button != self.dropInContentView.payPalButton) {
        [self.presentedViewController presentViewController:viewController animated:YES completion:nil];
    } else {
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)payPalButton:(__unused BTPayPalButton *)button requestsDismissalOfViewController:(UIViewController *)viewController {
    if (button != self.dropInContentView.payPalButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark PayPal Button Delegate methods

- (void)payPalButtonWillCreatePayPalPaymentMethod:(BTPayPalButton *)button {
    self.dropInContentView.state = BTDropInContentViewStateActivity;

    // Assign button to retainedPayPalButton to increment its reference count
    // This is a bit of duct-tape to make sure that the network activity and subsequent async
    // delegate method invoked by BTPayPalViewController is still executed even after
    // dismissal of the UI and release of encapsulating View Controller.
    // Reference count is decremented in subsequent delegate method calls. See below.
    self.retainedPayPalButton = button;
}

- (void)payPalButton:( __unused BTPayPalButton *)button didCreatePayPalPaymentMethod:(__unused BTPaymentMethod *)paymentMethod {
    NSMutableArray *newPaymentMethods = [NSMutableArray arrayWithArray:self.paymentMethods];
    [newPaymentMethods insertObject:paymentMethod atIndex:0];
    self.paymentMethods = newPaymentMethods;

    // Allow retained PayPal button to release, which will only happen if it isn't "ours"
    self.retainedPayPalButton = nil;
}

- (void)payPalButton:(BTPayPalButton *)button didFailWithError:(__unused NSError *)error {

    if (self.retainedPayPalButton != self.dropInContentView.payPalButton) {
        // Allow retained PayPal button to release, which will only happen if it isn't "ours"
        self.retainedPayPalButton = nil;

        self.savePayPalAccountErrorAlert = [[BTDropInErrorAlert alloc] initWithCancel:^{
            // Use the paymentMethods setter to update state
            [self setPaymentMethods:_paymentMethods];
            self.savePayPalAccountErrorAlert = nil;
        } retry:nil];
        self.savePayPalAccountErrorAlert.title = @"PayPal Error";
        self.savePayPalAccountErrorAlert.message = @"Please try again.";
        [self.savePayPalAccountErrorAlert show];
    } else {

        // Allow retained PayPal button to release, which will only happen if it isn't "ours"
        self.retainedPayPalButton = nil;

        self.savePayPalAccountErrorAlert = [[BTDropInErrorAlert alloc] initWithCancel:^{
            // Use the paymentMethods setter to update state
            [self setPaymentMethods:_paymentMethods];
            self.savePayPalAccountErrorAlert = nil;
        } retry:^{
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
            [self setPaymentMethods:_paymentMethods];
            self.savePayPalAccountErrorAlert = nil;
        }];
        self.savePayPalAccountErrorAlert.title = @"PayPal Error";
        [self.savePayPalAccountErrorAlert show];
    }
}

#pragma mark Delegate Notifications

- (void)informDelegateWillComplete {
    if ([self.delegate respondsToSelector:@selector(dropInViewControllerWillComplete:)]) {
        [self.delegate dropInViewControllerWillComplete:self];
    }
}

- (void)informDelegateDidAddPaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([self.delegate respondsToSelector:@selector(dropInViewController:didSucceedWithPaymentMethod:)]) {
        [self.delegate dropInViewController:self
                didSucceedWithPaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidCancel {
    if ([self.delegate respondsToSelector:@selector(dropInViewControllerDidCancel:)]) {
        [self.delegate dropInViewControllerDidCancel:self];
    }
}

#pragma mark User Supplied Parameters

- (void)setFullForm:(BOOL)fullForm {
    _fullForm = fullForm;
    if (!self.fullForm) {
        self.dropInContentView.state = BTDropInContentViewStateForm;
        
    }
}

- (void)setShouldHideCallToAction:(BOOL)shouldHideCallToAction {
    _shouldHideCallToAction = shouldHideCallToAction;
    self.dropInContentView.hideCTA = shouldHideCallToAction;

    self.submitBarButtonItem = shouldHideCallToAction ? [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                      target:self
                                                                                                      action:@selector(tappedSubmitForm)] : nil;
    self.submitBarButtonItem.style = UIBarButtonItemStyleDone;
    self.navigationItem.rightBarButtonItem = self.submitBarButtonItem;
}

- (void)setSummaryTitle:(NSString *)summaryTitle {
    _summaryTitle = summaryTitle;
    self.dropInContentView.summaryView.slug = summaryTitle;
    self.dropInContentView.hideSummary = (self.summaryTitle == nil || self.summaryDescription == nil);
}

- (void)setSummaryDescription:(__unused NSString *)summaryDescription {
    _summaryDescription = summaryDescription;
    self.dropInContentView.summaryView.summary = summaryDescription;
    self.dropInContentView.hideSummary = (self.summaryTitle == nil || self.summaryDescription == nil);
}

- (void)setDisplayAmount:(__unused NSString *)displayAmount {
    _displayAmount = displayAmount;
    self.dropInContentView.summaryView.amount = displayAmount;
}

- (void)setCallToActionText:(__unused NSString *)callToActionText {
    _callToActionText = callToActionText;
    self.dropInContentView.ctaControl.callToAction = callToActionText;
}

#pragma mark Data

- (void)setPaymentMethods:(NSArray *)paymentMethods {
    _paymentMethods = paymentMethods;
    BTDropInContentViewStateType newState;

    if ([self.paymentMethods count] == 0) {
        self.selectedPaymentMethodIndex = NSNotFound;
        newState = BTDropInContentViewStateForm;
    } else {
        self.selectedPaymentMethodIndex = 0;
        newState = BTDropInContentViewStatePaymentMethodsOnFile;
    }
    if (self.visible) {
        NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - self.visibleStartTime;
        if (elapsed < self.theme.minimumVisibilityTime) {
            NSTimeInterval delay = self.theme.minimumVisibilityTime - elapsed;

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.dropInContentView setState:newState animate:YES];
                [self updateValidity];
            });
            return;
        }
    }
    [self.dropInContentView setState:newState animate:self.visible];
    [self updateValidity];
}

- (void)setSelectedPaymentMethodIndex:(NSInteger)selectedPaymentMethodIndex {
    _selectedPaymentMethodIndex = selectedPaymentMethodIndex;
    if (selectedPaymentMethodIndex != NSNotFound) {
        BTPaymentMethod *defaultPaymentMethod = [self selectedPaymentMethod];
        if ([defaultPaymentMethod isKindOfClass:[BTCardPaymentMethod class]]) {
            BTUIPaymentMethodType uiPaymentMethodType = [BTDropInUtil uiForCardType:((BTCardPaymentMethod *)defaultPaymentMethod).type];
            self.dropInContentView.selectedPaymentMethodView.type =  uiPaymentMethodType;
        } else if ([defaultPaymentMethod isKindOfClass:[BTPayPalPaymentMethod class]]) {
            self.dropInContentView.selectedPaymentMethodView.type = BTUIPaymentMethodTypePayPal;
        } else {
            self.dropInContentView.selectedPaymentMethodView.type = BTUIPaymentMethodTypeUnknown;
        }
        self.dropInContentView.selectedPaymentMethodView.detailDescription = defaultPaymentMethod.description;
    }
    [self updateValidity];
}

- (BTPaymentMethod *)selectedPaymentMethod {
    return self.selectedPaymentMethodIndex != NSNotFound ? self.paymentMethods[self.selectedPaymentMethodIndex] : nil;
}

- (void)updateValidity {
    BTPaymentMethod *paymentMethod = [self selectedPaymentMethod];
    BOOL valid = paymentMethod != nil || (!self.dropInContentView.cardForm.hidden && self.dropInContentView.cardForm.valid);

    [self.navigationItem.rightBarButtonItem setEnabled:valid];
    [UIView animateWithDuration:self.theme.quickTransitionDuration animations:^{
        self.dropInContentView.ctaControl.enabled = valid;
    }];
}

- (BTUICardFormOptionalFields) optionalFieldsFromClientToken{
    NSSet *challenges = self.client.challenges;

    if ([challenges containsObject:@"cvv"] && [challenges containsObject:@"postal_code"]) {
        return BTUICardFormOptionalFieldsAll;
    } else if ([challenges containsObject:@"cvv"]){
        return BTUICardFormOptionalFieldsCvv;
    } else if ([challenges containsObject:@"postal_code"]){
        return BTUICardFormOptionalFieldsPostalCode;
    } else {
        return BTUICardFormOptionalFieldsNone;
    }
}

- (void)fetchPaymentMethods{
    BOOL networkActivityIndicatorState = [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [self.client fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:networkActivityIndicatorState];
        self.paymentMethods = paymentMethods;
    } failure:^(__unused NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:networkActivityIndicatorState];

        self.fetchPaymentMethodsErrorAlert = [[BTDropInErrorAlert alloc] initWithCancel:^{
            [self informDelegateDidCancel];
            self.fetchPaymentMethodsErrorAlert = nil;
        } retry:^{
            [self fetchPaymentMethods];
            self.fetchPaymentMethodsErrorAlert = nil;
        }];

        [self.fetchPaymentMethodsErrorAlert show];
    }];
}

#pragma mark - Helpers

- (BTDropInViewController *)addPaymentMethodDropInViewController {
    BTDropInViewController *addPaymentMethodViewController = [[BTDropInViewController alloc] initWithClient:self.client];
    addPaymentMethodViewController.title = @"Add Payment Method";
    addPaymentMethodViewController.fullForm = NO;
    addPaymentMethodViewController.shouldHideCallToAction = YES;
    addPaymentMethodViewController.delegate = self;
    addPaymentMethodViewController.dropInContentView.payPalButton.delegate = self;
    addPaymentMethodViewController.dropInContentView.payPalButton.presentationDelegate = self;
    return addPaymentMethodViewController;
}

@end
