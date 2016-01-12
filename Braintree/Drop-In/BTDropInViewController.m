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
#import "BTDropInLocalizedString.h"
#import "BTPaymentMethodCreationDelegate.h"
#import "BTClient_Internal.h"
#import "BTLogger_Internal.h"
#import "BTCoinbase.h"

@interface BTDropInViewController () < BTDropInSelectPaymentMethodViewControllerDelegate, BTUIScrollViewScrollRectToVisibleDelegate, BTUICardFormViewDelegate, BTPaymentMethodCreationDelegate, BTDropInViewControllerDelegate>

@property (nonatomic, strong) BTDropInContentView *dropInContentView;
@property (nonatomic, strong) BTDropInViewController *addPaymentMethodDropInViewController;
@property (nonatomic, strong) BTUIScrollView *scrollView;
@property (nonatomic, assign) NSInteger selectedPaymentMethodIndex;
@property (nonatomic, strong) UIBarButtonItem *submitBarButtonItem;

/// Whether currently visible.
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) NSTimeInterval visibleStartTime;

/// If YES, fetch and display payment methods on file, summary view, CTA control.
/// If NO, do not fetch payment methods, and just show UI to add a new method.
///
/// Defaults to `YES`.
@property (nonatomic, assign) BOOL fullForm;

/// Strong reference to a BTDropInErrorAlert. Reference is needed to
/// handle user input from UIAlertView.
@property (nonatomic, strong) BTDropInErrorAlert *fetchPaymentMethodsErrorAlert;

/// Strong reference to  BTDropInErrorAlert. Reference is needed to
/// handle user input from UIAlertView.
@property (nonatomic, strong) BTDropInErrorAlert *saveAccountErrorAlert;

@property (nonatomic, assign) BOOL cardEntryDidBegin;

@property (nonatomic, assign) BOOL originalCoinbaseStoreInVault;

@end

@implementation BTDropInViewController

- (instancetype)initWithClient:(BTClient *)client {
    self = [self init];
    if (self) {
        self.theme = [BTUI braintreeTheme];
        self.dropInContentView = [[BTDropInContentView alloc] init];

        self.client = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
            metadata.integration = BTClientMetadataIntegrationDropIn;
        }];
        self.dropInContentView.paymentButton.client = self.client;
        self.dropInContentView.paymentButton.delegate = self;

        self.dropInContentView.hidePaymentButton = !self.dropInContentView.paymentButton.hasAvailablePaymentMethod;

        self.selectedPaymentMethodIndex = NSNotFound;
        self.dropInContentView.state = BTDropInContentViewStateActivity;
        self.fullForm = YES;
        _callToActionText = BTDropInLocalizedString(DEFAULT_CALL_TO_ACTION);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.dropInContentView.cardFormSectionHeader.text = BTDropInLocalizedString(CARD_FORM_SECTION_HEADER);


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

    if (self.fullForm) {
        [self.client postAnalyticsEvent:@"dropin.ios.appear"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Quickly fade out the content view to prevent a jarring effect
    // as keyboard dimisses.
    [UIView animateWithDuration:self.theme.quickTransitionDuration animations:^{
        self.dropInContentView.alpha = 0.0f;
    }];
    if (self.fullForm) {
        [self.client postAnalyticsEvent:@"dropin.ios.disappear"];
    }
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
        rootViewController = self.addPaymentMethodDropInViewController;
    } else {
        BTDropInSelectPaymentMethodViewController *selectPaymentMethod = [[BTDropInSelectPaymentMethodViewController alloc] init];
        selectPaymentMethod.title = BTDropInLocalizedString(SELECT_PAYMENT_METHOD_TITLE);
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
        [self showLoadingState:NO];
        [self informDelegateWillComplete];
        [self informDelegateDidAddPaymentMethod:paymentMethod];
    } else if (!self.dropInContentView.cardForm.hidden) {
        BTUICardFormView *cardForm = self.dropInContentView.cardForm;

        BTClient *client = [self.client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
            metadata.source = BTClientMetadataSourceForm;
        }];

        if (cardForm.valid) {
            [self informDelegateWillComplete];

            BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
            request.number = cardForm.number;
            request.expirationMonth = cardForm.expirationMonth;
            request.expirationYear = cardForm.expirationYear;
            request.cvv = cardForm.cvv;
            request.postalCode = cardForm.postalCode;
            request.shouldValidate = YES;

            [client postAnalyticsEvent:@"dropin.ios.add-card.save"];
            [client saveCardWithRequest:request
                                success:^(BTCardPaymentMethod *card) {
                                    [client postAnalyticsEvent:@"dropin.ios.add-card.success"];
                                    [self showLoadingState:NO];
                                    [self informDelegateDidAddPaymentMethod:card];
                                }
                                failure:^(NSError *error) {
                                    [self showLoadingState:NO];
                                    [client postAnalyticsEvent:@"dropin.ios.add-card.failed"];
                                    if ([error.domain isEqualToString:BTBraintreeAPIErrorDomain] && error.code == BTCustomerInputErrorInvalid) {
                                        [self informUserDidFailWithError:error];
                                    }
                                }];
        } else {
            NSString *localizedAlertTitle = BTDropInLocalizedString(ERROR_SAVING_CARD_ALERT_TITLE);
            NSString *localizedAlertMessage = BTDropInLocalizedString(ERROR_SAVING_CARD_MESSAGE);
            BTDropInErrorAlert *alert = [[BTDropInErrorAlert alloc] initWithCancel:nil retry:nil];
            alert.title = localizedAlertTitle;
            alert.message = localizedAlertMessage;
            [alert show];
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

    if (!self.cardEntryDidBegin) {
        [self.client postAnalyticsEvent:@"dropin.ios.add-card.start"];
        self.cardEntryDidBegin = YES;
    }

    [self updateValidity];
}

#pragma mark Drop In Select Payment Method Table View Controller Delegate methods

- (void)selectPaymentMethodViewController:(BTDropInSelectPaymentMethodViewController *)viewController
            didSelectPaymentMethodAtIndex:(NSUInteger)index {
    self.selectedPaymentMethodIndex = index;
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectPaymentMethodViewControllerDidRequestNew:(BTDropInSelectPaymentMethodViewController *)viewController {
    [viewController.navigationController pushViewController:self.addPaymentMethodDropInViewController animated:YES];
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

#pragma mark BTPaymentMethodCreationDelegate

- (void)paymentMethodCreator:(__unused id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
    // In order to modally present PayPal on top of a nested Drop In, we need to first dismiss the
    // nested Drop In. Canceling will return to the outer Drop In.
    if ([self presentedViewController]) {
        BTDropInContentViewStateType originalState = self.dropInContentView.state;
        self.dropInContentView.state = BTDropInContentViewStateActivity;
        [self dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:viewController animated:YES completion:^{
                self.dropInContentView.state = originalState;
            }];
        }];
    } else {
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)paymentMethodCreator:(__unused id)sender requestsDismissalOfViewController:(__unused UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(__unused id)sender {
    // If there is a presented view controller, dismiss it before app switch
    // so that the result of the app switch can be shown in this view controller.
    if ([self presentedViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)paymentMethodCreatorWillProcess:(__unused id)sender {
    self.dropInContentView.state = BTDropInContentViewStateActivity;

    self.originalCoinbaseStoreInVault = [[BTCoinbase sharedCoinbase] storeInVault];
    [[BTCoinbase sharedCoinbase] setStoreInVault:YES];
}

- (void)paymentMethodCreator:(__unused id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [[BTCoinbase sharedCoinbase] setStoreInVault:self.originalCoinbaseStoreInVault];

    NSMutableArray *newPaymentMethods = [NSMutableArray arrayWithArray:self.paymentMethods];
    [newPaymentMethods insertObject:paymentMethod atIndex:0];
    self.paymentMethods = newPaymentMethods;

    // Let the addPaymentMethodDropInViewController release
    self.addPaymentMethodDropInViewController = nil;
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error {
    [[BTCoinbase sharedCoinbase] setStoreInVault:self.originalCoinbaseStoreInVault];

    NSString *savePaymentMethodErrorAlertTitle;
    if ([error localizedDescription]) {
        savePaymentMethodErrorAlertTitle = [error localizedDescription];
    } else {
        savePaymentMethodErrorAlertTitle = BTDropInLocalizedString(ERROR_ALERT_CONNECTION_ERROR);
    }

    if (sender != self.dropInContentView.paymentButton) {

        self.saveAccountErrorAlert = [[BTDropInErrorAlert alloc] initWithCancel:^{
            // Use the paymentMethods setter to update state
            [self setPaymentMethods:_paymentMethods];
            self.saveAccountErrorAlert = nil;
        } retry:nil];
        self.saveAccountErrorAlert.title = savePaymentMethodErrorAlertTitle;
        [self.saveAccountErrorAlert show];
    } else {
        self.saveAccountErrorAlert = [[BTDropInErrorAlert alloc] initWithCancel:^{
            // Use the paymentMethods setter to update state
            [self setPaymentMethods:_paymentMethods];
            self.saveAccountErrorAlert = nil;
        } retry:nil];
        self.saveAccountErrorAlert.title = savePaymentMethodErrorAlertTitle;
        [self.saveAccountErrorAlert show];
    }

    // Let the addPaymentMethodDropInViewController release
    self.addPaymentMethodDropInViewController = nil;
}

- (void)paymentMethodCreatorDidCancel:(__unused id)sender {
    [[BTCoinbase sharedCoinbase] setStoreInVault:self.originalCoinbaseStoreInVault];

    // Refresh payment methods display
    self.paymentMethods = self.paymentMethods;

    // Let the addPaymentMethodDropInViewController release
    self.addPaymentMethodDropInViewController = nil;
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
        } else if ([defaultPaymentMethod isKindOfClass:[BTCoinbasePaymentMethod class]]) {
            self.dropInContentView.selectedPaymentMethodView.type = BTUIPaymentMethodTypeCoinbase;
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
    BOOL valid = (paymentMethod != nil) || (!self.dropInContentView.cardForm.hidden && self.dropInContentView.cardForm.valid);

    [self.navigationItem.rightBarButtonItem setEnabled:valid];
    [UIView animateWithDuration:self.theme.quickTransitionDuration animations:^{
        self.dropInContentView.ctaControl.enabled = valid;
    }];
}

- (BTUICardFormOptionalFields)optionalFieldsFromClientToken {
    NSSet *challenges = self.client.challenges;

    static NSString *cvvChallenge = @"cvv";
    static NSString *postalCodeChallenge = @"postal_code";

    if ([challenges containsObject:cvvChallenge] && [challenges containsObject:postalCodeChallenge]) {
        return BTUICardFormOptionalFieldsAll;
    } else if ([challenges containsObject:cvvChallenge]) {
        return BTUICardFormOptionalFieldsCvv;
    } else if ([challenges containsObject:postalCodeChallenge]) {
        return BTUICardFormOptionalFieldsPostalCode;
    } else {
        return BTUICardFormOptionalFieldsNone;
    }
}

- (void)fetchPaymentMethods {
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
    if (!_addPaymentMethodDropInViewController) {
        _addPaymentMethodDropInViewController = [[BTDropInViewController alloc] initWithClient:self.client];

        _addPaymentMethodDropInViewController.title = BTDropInLocalizedString(ADD_PAYMENT_METHOD_VIEW_CONTROLLER_TITLE);
        _addPaymentMethodDropInViewController.fullForm = NO;
        _addPaymentMethodDropInViewController.shouldHideCallToAction = YES;
        _addPaymentMethodDropInViewController.delegate = self;
        _addPaymentMethodDropInViewController.dropInContentView.paymentButton.delegate = self;
    }
    return _addPaymentMethodDropInViewController;
}

@end
