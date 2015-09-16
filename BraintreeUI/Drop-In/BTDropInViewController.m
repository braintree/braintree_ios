#import "BTAPIClient_Internal.h"
#import "BTDropInViewController.h"
#import "BTDropInContentView.h"
#import "BTDropInSelectPaymentMethodViewController.h"
#import "BTUICardFormView.h"
#import "BTUIScrollView.h"
#import "BTDropInUtil.h"
#import "BTDropInErrorState.h"
#import "BTDropInErrorAlert.h"
#import "BTDropInLocalizedString.h"
#import "BTTokenizationParser.h"
#import "BTTokenizationService.h"

@interface BTDropInViewController () <BTUIScrollViewScrollRectToVisibleDelegate, BTUICardFormViewDelegate, BTDropInViewControllerDelegate, BTDropInSelectPaymentMethodViewControllerDelegate, BTViewControllerPresentingDelegate>

@property (nonatomic, strong) BTDropInContentView *dropInContentView;
@property (nonatomic, strong) BTDropInViewController *addPaymentMethodDropInViewController;
@property (nonatomic, strong) BTUIScrollView *scrollView;
@property (nonatomic, assign) NSInteger selectedPaymentInfoIndex;
@property (nonatomic, strong) UIBarButtonItem *submitBarButtonItem;

/// Whether currently visible.
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) NSTimeInterval visibleStartTime;

/// If YES, fetch and display payment methods on file, summary view, CTA control.
/// If NO, do not fetch payment methods, and just show UI to add a new method.
///
/// Defaults to `YES`.
@property (nonatomic, assign) BOOL fullForm;

@property (nonatomic, assign) BOOL cardEntryDidBegin;

@property (nonatomic, assign) BOOL originalCoinbaseStoreInVault;

@end

@implementation BTDropInViewController

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        self.theme = [BTUI braintreeTheme];
        self.dropInContentView = [[BTDropInContentView alloc] init];
        self.dropInContentView.paymentButton.viewControllerPresentingDelegate = self;

        self.apiClient = [apiClient copyWithSource:BTClientMetadataSourceUnknown integration:BTClientMetadataIntegrationDropIn];
        self.dropInContentView.paymentButton.apiClient = self.apiClient;
        __weak typeof(self) weakSelf = self;
        self.dropInContentView.paymentButton.completion = ^(id<BTTokenized> tokenization, NSError *error) {
            // TODO: uncomment when BTCoinbase is implemented?
            //    [[BTCoinbase sharedCoinbase] setStoreInVault:self.originalCoinbaseStoreInVault];

            if (error) {
                NSString *savePaymentMethodErrorAlertTitle = error.localizedDescription ?: BTDropInLocalizedString(ERROR_ALERT_CONNECTION_ERROR);

                BTDropInErrorAlert *errorAlert = [[BTDropInErrorAlert alloc] initWithPresentingViewController:weakSelf];
                errorAlert.title = savePaymentMethodErrorAlertTitle;
                errorAlert.cancelBlock = ^{
                    // Use the paymentInfoObjects setter to update state
                    weakSelf.paymentInfoObjects = weakSelf.paymentInfoObjects;
                };

                [errorAlert show];
            } else if (tokenization) {
                NSMutableArray *newPaymentMethods = [NSMutableArray arrayWithArray:weakSelf.paymentInfoObjects];
                [newPaymentMethods insertObject:tokenization atIndex:0];
                weakSelf.paymentInfoObjects = newPaymentMethods;
            } else {
                // Refresh payment methods display
                weakSelf.paymentInfoObjects = weakSelf.paymentInfoObjects;
                NSLog(@"User cancelled payment");
            }

            // Let the addPaymentMethodDropInViewController release
            weakSelf.addPaymentMethodDropInViewController = nil;
        };

        self.dropInContentView.hidePaymentButton = !self.dropInContentView.paymentButton.hasAvailablePaymentMethod;

        self.selectedPaymentInfoIndex = NSNotFound;
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

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {

        if (!self.delegate) {
            // Report integration error, as a delegate is required by this point
            NSLog(@"ERROR: Drop-in delegate not set");
        }

        // Drop-in view controller remains in a loading state until this is set
        self.paymentInfoObjects = self.paymentInfoObjects;

        if (error) {
            BTDropInErrorAlert *errorAlert = [[BTDropInErrorAlert alloc] initWithPresentingViewController:self];
            errorAlert.title = error.localizedDescription ?: BTDropInLocalizedString(ERROR_ALERT_CONNECTION_ERROR);
            [errorAlert show];
        }

        NSArray *challenges = configuration.json[@"challenges"].asArray;

        static NSString *cvvChallenge = @"cvv";
        static NSString *postalCodeChallenge = @"postal_code";

        BTUICardFormOptionalFields optionalFields;
        if ([challenges containsObject:cvvChallenge] && [challenges containsObject:postalCodeChallenge]) {
            optionalFields = BTUICardFormOptionalFieldsAll;
        } else if ([challenges containsObject:cvvChallenge]) {
            optionalFields = BTUICardFormOptionalFieldsCvv;
        } else if ([challenges containsObject:postalCodeChallenge]) {
            optionalFields = BTUICardFormOptionalFieldsPostalCode;
        } else {
            optionalFields = BTUICardFormOptionalFieldsNone;
        }

        self.dropInContentView.cardForm.optionalFields = optionalFields;
    }];



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
        [self.apiClient sendAnalyticsEvent:@"dropin.ios.appear"];
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
        [self.apiClient sendAnalyticsEvent:@"dropin.ios.disappear"];
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
    if (self.paymentInfoObjects.count == 1) {
        rootViewController = self.addPaymentMethodDropInViewController;
    } else {
        BTDropInSelectPaymentMethodViewController *selectPaymentMethod = [[BTDropInSelectPaymentMethodViewController alloc] init];
        selectPaymentMethod.title = BTDropInLocalizedString(SELECT_PAYMENT_METHOD_TITLE);
        selectPaymentMethod.theme = self.theme;
        selectPaymentMethod.paymentInfoObjects = self.paymentInfoObjects;
        selectPaymentMethod.selectedPaymentMethodIndex = self.selectedPaymentInfoIndex;
        selectPaymentMethod.delegate = self;
        selectPaymentMethod.client = self.apiClient;
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

    id<BTTokenized> paymentInfo = [self selectedPaymentMethod];
    if (paymentInfo != nil) {
        [self informDelegateWillComplete];
        [self informDelegateDidAddPaymentInfo:paymentInfo];
    } else if (!self.dropInContentView.cardForm.hidden) {
        BTUICardFormView *cardForm = self.dropInContentView.cardForm;

        BTAPIClient *client = [self.apiClient copyWithSource:BTClientMetadataSourceForm integration:BTClientMetadataIntegrationDropIn];

        if (cardForm.valid) {
            [self informDelegateWillComplete];

            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            options[@"number"] = cardForm.number;
            options[@"expiration_date"] = [NSString stringWithFormat:@"%@/%@", cardForm.expirationMonth, cardForm.expirationYear];
            if (cardForm.cvv) {
                options[@"cvv"] = cardForm.cvv;
            }
            if (cardForm.postalCode) {
                options[@"billing_address"] = @{ @"postal_code": cardForm.postalCode };
            }
            // 2015-08-17: Client Key does not support validation
            // TODO: Double-check that this is desired behavior
            options[@"options"] = @{ @"validate" : @(self.apiClient.clientKey ? NO : YES) };

            [client sendAnalyticsEvent:@"dropin.ios.add-card.save"];

            [[BTTokenizationService sharedService] tokenizeType:@"Card" options:options withAPIClient:client completion:^(id<BTTokenized> tokenization, NSError *error) {
                [self showLoadingState:NO];

                if (error) {
                    [client sendAnalyticsEvent:@"dropin.ios.add-card.failed"];
                    // TODO: fix this grossness
                    if ([error.domain isEqualToString:@"com.braintreepayments.BTCardClientErrorDomain"] && error.code == BTErrorCustomerInputInvalid) {
                        [self informUserDidFailWithError:error];
                    } else {
                        BTDropInErrorAlert *errorAlert = [[BTDropInErrorAlert alloc] initWithPresentingViewController:self];
                        errorAlert.title = BTDropInLocalizedString(ERROR_SAVING_CARD_ALERT_TITLE);
                        errorAlert.message = error.localizedDescription;
                        __weak typeof(self) weakSelf = self;
                        errorAlert.cancelBlock = ^{
                            // Use the paymentInfoObjects setter to update state
                            weakSelf.paymentInfoObjects = weakSelf.paymentInfoObjects;
                        };
                        [errorAlert show];
                    }
                    return;
                }

                [client sendAnalyticsEvent:@"dropin.ios.add-card.success"];
                [self informDelegateDidAddPaymentInfo:tokenization];

                // Let the view controller release
                self.addPaymentMethodDropInViewController = nil;
            }];
        } else {
            BTDropInErrorAlert *alert = [[BTDropInErrorAlert alloc] initWithPresentingViewController:self];
            alert.title = BTDropInLocalizedString(ERROR_SAVING_CARD_ALERT_TITLE);
            alert.message = BTDropInLocalizedString(ERROR_SAVING_CARD_MESSAGE);
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
        [self.apiClient sendAnalyticsEvent:@"dropin.ios.add-card.start"];
        self.cardEntryDidBegin = YES;
    }

    [self updateValidity];
}

#pragma mark Drop In Select Payment Method Table View Controller Delegate methods

- (void)selectPaymentMethodViewController:(BTDropInSelectPaymentMethodViewController *)viewController
            didSelectPaymentMethodAtIndex:(NSUInteger)index {
    self.selectedPaymentInfoIndex = index;
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectPaymentMethodViewControllerDidRequestNew:(BTDropInSelectPaymentMethodViewController *)viewController {
    [viewController.navigationController pushViewController:self.addPaymentMethodDropInViewController animated:YES];
}

#pragma mark BTDropInViewControllerDelegate implementation

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithTokenization:(id<BTTokenized> )paymentMethod {
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];

    NSMutableArray *newPaymentMethods = [NSMutableArray arrayWithArray:self.paymentInfoObjects];
    [newPaymentMethods insertObject:paymentMethod atIndex:0];
    self.paymentInfoObjects = newPaymentMethods;
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController {
    [viewController.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark BTAppSwitchDelegate

//- (void)paymentDriver:(__unused id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
//    // In order to modally present PayPal on top of a nested Drop In, we need to first dismiss the
//    // nested Drop In. Canceling will return to the outer Drop In.
//    if ([self presentedViewController]) {
//        BTDropInContentViewStateType originalState = self.dropInContentView.state;
//        self.dropInContentView.state = BTDropInContentViewStateActivity;
//        [self dismissViewControllerAnimated:YES completion:^{
//            [self presentViewController:viewController animated:YES completion:^{
//                self.dropInContentView.state = originalState;
//            }];
//        }];
//    } else {
//        [self presentViewController:viewController animated:YES completion:nil];
//    }
//}
//
//- (void)paymentDriver:(__unused id)sender requestsDismissalOfViewController:(__unused UIViewController *)viewController {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}


// TODO: What are some possible presented view controller(s)?
- (void)paymentDriverWillPerformAppSwitch:(__unused id)sender {
    // If there is a presented view controller, dismiss it before app switch
    // so that the result of the app switch can be shown in this view controller.
    if ([self presentedViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// TODO

//- (void)paymentDriverWillProcess:(__unused id)sender {
//    self.dropInContentView.state = BTDropInContentViewStateActivity;
//
//    self.originalCoinbaseStoreInVault = [[BTCoinbase sharedCoinbase] storeInVault];
//    [[BTCoinbase sharedCoinbase] setStoreInVault:YES];
//}


#pragma mark Delegate Notifications

- (void)informDelegateWillComplete {
    if ([self.delegate respondsToSelector:@selector(dropInViewControllerWillComplete:)]) {
        [self.delegate dropInViewControllerWillComplete:self];
    }
}

- (void)informDelegateDidAddPaymentInfo:(id<BTTokenized> )paymentMethod {
    if ([self.delegate respondsToSelector:@selector(dropInViewController:didSucceedWithTokenization:)]) {
        [self.delegate dropInViewController:self
                didSucceedWithTokenization:paymentMethod];
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

- (void)setPaymentInfoObjects:(NSArray *)paymentInfoObjects {
    _paymentInfoObjects = paymentInfoObjects;
    BTDropInContentViewStateType newState;

    if ([self.paymentInfoObjects count] == 0) {
        self.selectedPaymentInfoIndex = NSNotFound;
        newState = BTDropInContentViewStateForm;
    } else {
        self.selectedPaymentInfoIndex = 0;
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

- (void)setSelectedPaymentInfoIndex:(NSInteger)selectedPaymentInfoIndex {
    _selectedPaymentInfoIndex = selectedPaymentInfoIndex;
    if (_selectedPaymentInfoIndex != NSNotFound) {
        id<BTTokenized> defaultPaymentMethod = [self selectedPaymentMethod];
        BTUIPaymentOptionType paymentMethodType = [BTUI paymentOptionTypeForPaymentInfoType:defaultPaymentMethod.type];
        self.dropInContentView.selectedPaymentMethodView.type = paymentMethodType;
        self.dropInContentView.selectedPaymentMethodView.detailDescription = defaultPaymentMethod.localizedDescription;
    }
    [self updateValidity];
}

- (id<BTTokenized>)selectedPaymentMethod {
    return self.selectedPaymentInfoIndex != NSNotFound ? self.paymentInfoObjects[self.selectedPaymentInfoIndex] : nil;
}

- (void)updateValidity {
    id<BTTokenized> paymentMethod = [self selectedPaymentMethod];
    BOOL valid = (paymentMethod != nil) || (!self.dropInContentView.cardForm.hidden && self.dropInContentView.cardForm.valid);

    [self.navigationItem.rightBarButtonItem setEnabled:valid];
    [UIView animateWithDuration:self.theme.quickTransitionDuration animations:^{
        self.dropInContentView.ctaControl.enabled = valid;
    }];
}

- (void)fetchPaymentMethodsOnCompletion:(void(^)())completionBlock {
    if (self.apiClient.clientKey) {
        if (completionBlock) completionBlock();
        return;
    }
    
    BOOL networkActivityIndicatorState = [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.apiClient GET:@"v1/payment_methods"
             parameters:nil
             completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:networkActivityIndicatorState];

                     if (error) {
                         BTDropInErrorAlert *errorAlert = [[BTDropInErrorAlert alloc] initWithPresentingViewController:self];
                         errorAlert.title = error.localizedDescription;
                         BTJSON *errorBody = error.userInfo[BTHTTPJSONResponseBodyKey];
                         errorAlert.message = errorBody[@"error"][@"message"].asString;
                         errorAlert.cancelBlock = ^{
                             [self informDelegateDidCancel];
                             if (completionBlock) completionBlock();
                         };
                         errorAlert.retryBlock = ^{
                             [self fetchPaymentMethodsOnCompletion:completionBlock];
                         };
                         [errorAlert show];

                         return;
                     }

                     NSMutableArray *paymentInfoObjects = [NSMutableArray array];
                     for (NSDictionary *paymentInfo in body[@"paymentMethods"].asArray) {
                         BTJSON *paymentInfoJSON = [[BTJSON alloc] initWithValue:paymentInfo];
                         id <BTTokenized> tokenization = [[BTTokenizationParser sharedParser] parseJSON:paymentInfoJSON withParsingBlockForType:paymentInfoJSON[@"type"].asString];
                         if (tokenization) [paymentInfoObjects addObject:tokenization];
                     }
                     if (paymentInfoObjects.count) {
                         self.paymentInfoObjects = [paymentInfoObjects copy];
                     }
                     if (completionBlock) completionBlock();
                 });
    }];
}

#pragma mark - Helpers

- (BTDropInViewController *)addPaymentMethodDropInViewController {
    if (!_addPaymentMethodDropInViewController) {
        _addPaymentMethodDropInViewController = [[BTDropInViewController alloc] initWithAPIClient:self.apiClient];

        _addPaymentMethodDropInViewController.title = BTDropInLocalizedString(ADD_PAYMENT_METHOD_VIEW_CONTROLLER_TITLE);
        _addPaymentMethodDropInViewController.fullForm = NO;
        _addPaymentMethodDropInViewController.shouldHideCallToAction = YES;
        _addPaymentMethodDropInViewController.delegate = self;
//        _addPaymentMethodDropInViewController.dropInContentView.paymentButton.delegate = self;
    }
    return _addPaymentMethodDropInViewController;
}

#pragma mark - BTViewControllerPresentingDelegate

- (void)paymentDriver:(__unused id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(__unused id)driver requestsDismissalOfViewController:(__unused UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
