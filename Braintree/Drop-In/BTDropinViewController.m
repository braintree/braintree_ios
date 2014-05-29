#import "BTDropInViewController.h"
#import "BTDropInContentView.h"
#import "BTDropInUtil.h"
#import "BTDropInSelectPaymentMethodViewController.h"
#import "BTUICardFormView.h"
#import "BTUIScrollView.h"
#import "Braintree-API.h"
#import "BTClient+BTPayPal.h"

@interface BTDropInViewController () < BTDropInSelectPaymentMethodViewControllerDelegate, BTUIScrollViewScrollRectToVisibleDelegate, BTUICardFormViewDelegate, BTPayPalControlViewControllerPresenterDelegate, BTPayPalControlDelegate>
@property (nonatomic, strong) BTDropInContentView *dropInContentView;
@property (nonatomic, strong) BTUIScrollView *scrollView;
@property (nonatomic, strong) NSArray *paymentMethods;
@property (nonatomic, assign) NSInteger selectedPaymentMethodIndex;
@end

@implementation BTDropInViewController

- (instancetype)initWithClient:(BTClient *)client {
    self = [self init];
    if (self) {
        self.theme = [BTUI braintreeTheme];
        self.client = client;
        self.dropInContentView = [[BTDropInContentView alloc] init];
        self.dropInContentView.payPalControl.client = self.client;
        self.dropInContentView.payPalControl.presentationDelegate = self;
        self.dropInContentView.payPalControl.delegate = self;
        self.dropInContentView.payPalControlHidden =  !self.client.btPayPal_isPayPalEnabled;
        self.selectedPaymentMethodIndex = NSNotFound;
        self.shouldDisplayPaymentMethodsOnFile = YES;
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
    self.scrollView.delaysContentTouches = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
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

    if (self.shouldDisplayPaymentMethodsOnFile) {
        [self fetchPaymentMethods];
    }

    [self updateValidity];
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
    CGRect desiredVisibleBottomRect = [self.scrollView convertRect:self.dropInContentView.ctaControl.frame fromView:self.dropInContentView];

    CGFloat visibleAreaHeight = self.scrollView.frame.size.height - self.scrollView.contentInset.bottom - self.scrollView.contentInset.top;

    CGRect weightedBottomRect = CGRectUnion(targetRect, desiredVisibleBottomRect);
    if (weightedBottomRect.size.height <= visibleAreaHeight) {
        targetRect = weightedBottomRect;
    }

    CGRect weightedTopRect = CGRectUnion(targetRect, desiredVisibleTopRect);
    if (weightedTopRect.size.height <= visibleAreaHeight) {
        targetRect = weightedTopRect;
        targetRect.size.height = visibleAreaHeight;
    }

    [scrollView defaultScrollRectToVisible:targetRect animated:animated];
}

#pragma mark - Keyboard behavior

- (void)keyboardDidHide:(__unused NSNotification *)inputViewNotification {
    [self updateScrollViewInsets:inputViewNotification];
}

- (void)keyboardWillShow:(__unused NSNotification *)inputViewNotification {
    [self updateScrollViewInsets:inputViewNotification];
}

- (void)keyboardDidShow:(__unused NSNotification *)inputViewNotification {
}

- (void)updateScrollViewInsets:(NSNotification *)inputViewNotification {
    CGRect inputViewFrame = [[[inputViewNotification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect inputViewFrameInView = [self.view convertRect:inputViewFrame fromView:nil];
    CGRect intersection = CGRectIntersection(self.scrollView.frame, inputViewFrameInView);
    UIEdgeInsets ei = UIEdgeInsetsMake(0.0, 0.0, intersection.size.height, 0.0);
    self.scrollView.scrollIndicatorInsets = ei;
    self.scrollView.contentInset = ei;
}

#pragma mark - Handlers

- (void)tappedChangePaymentMethod {
    BTDropInSelectPaymentMethodViewController *selectPaymentMethod = [[BTDropInSelectPaymentMethodViewController alloc] init];
    selectPaymentMethod.theme = self.theme;
    selectPaymentMethod.paymentMethods = self.paymentMethods;
    selectPaymentMethod.selectedPaymentMethodIndex = self.selectedPaymentMethodIndex;
    selectPaymentMethod.delegate = self;
    selectPaymentMethod.client = self.client;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:selectPaymentMethod];

    [self presentViewController:navController animated:YES completion:nil];
}

- (void)tappedSubmitForm {

    BTPaymentMethod *paymentMethod = [self selectedPaymentMethod];
    if (paymentMethod != nil) {
        [self informDelegateDidAddPaymentMethod:paymentMethod];
    } else if (!self.dropInContentView.cardForm.hidden) {
        BTUICardFormView *cardForm = self.dropInContentView.cardForm;
        if (cardForm.valid) {
            [self.client saveCardWithNumber:cardForm.number
                            expirationMonth:cardForm.expirationMonth
                             expirationYear:cardForm.expirationYear
                                        cvv:cardForm.cvv
                                 postalCode:cardForm.postalCode
                                   validate:YES
                                    success:^(BTCardPaymentMethod *card) {
                                        [self informDelegateDidAddPaymentMethod:card];
                                    }
                                    failure:^(NSError *error) {
                                        [self informDelegateDidFailWithError:error];
                                    }];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Invalid form"
                                        message:@"The card form is invalid"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    } else {
        [self informDelegateDidAddPaymentMethod:[self selectedPaymentMethod]];

    }
}

#pragma mark Card Form Delegate methods

- (void)cardFormViewDidChange:(__unused BTUICardFormView *)cardFormView {
    [self updateValidity];
}

#pragma mark Drop In Select Payment Method Table View Controller Delegate methods

- (void)dropInSelectPaymentMethodViewController:(__unused BTDropInSelectPaymentMethodViewController *)viewController didSelectPaymentMethodAtIndex:(NSUInteger)index {
    self.selectedPaymentMethodIndex = index;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInSelectPaymentMethodViewControllerDidCancel:(__unused BTDropInSelectPaymentMethodViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInSelectPaymentMethodViewController:(__unused BTDropInSelectPaymentMethodViewController *)viewController
                              didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    NSMutableArray *newPaymentMethods = [NSMutableArray arrayWithArray:self.paymentMethods];
    [newPaymentMethods insertObject:paymentMethod atIndex:0];
    self.paymentMethods = newPaymentMethods;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PayPal Control Presentation Delegate methods

- (void)payPalControl:(__unused BTPayPalControl *)control requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)payPalControl:(__unused BTPayPalControl *)control requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PayPal Control Delegate methods

- (void)payPalControl:(__unused BTPayPalControl *)control didCreatePayPalPaymentMethod:(__unused BTPaymentMethod *)paymentMethod {
    NSMutableArray *newPaymentMethods = [NSMutableArray arrayWithArray:self.paymentMethods];
    [newPaymentMethods insertObject:paymentMethod atIndex:0];
    self.paymentMethods = newPaymentMethods;
}

- (void)payPalControl:(__unused BTPayPalControl *)control didFailWithError:(__unused NSError *)error {
    [self informDelegateDidFailWithError:error];
}

#pragma mark Delegate Notifications

- (void)informDelegateDidAddPaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([self.delegate respondsToSelector:@selector(dropInViewController:didSucceedWithPaymentMethod:)]) {
        [self.delegate dropInViewController:self
                didSucceedWithPaymentMethod:paymentMethod];
    }

    if (self.paymentMethodCompletionBlock) {
        self.paymentMethodCompletionBlock(paymentMethod, nil);
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    self.paymentMethodCompletionBlock(nil, error);
    if ([self.delegate respondsToSelector:@selector(dropInViewController:didFailWithError:)]) {
        [self.delegate dropInViewController:self
                           didFailWithError:error];
    }
}

#pragma mark User Supplied Parameters

- (void)setShouldHideCallToAction:(BOOL)shouldHideCallToAction {
    _shouldHideCallToAction = shouldHideCallToAction;
    self.dropInContentView.hideCTA = shouldHideCallToAction;
    self.navigationItem.rightBarButtonItem = shouldHideCallToAction ? [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                                    target:self
                                                                                                                    action:@selector(tappedSubmitForm)] : nil;
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

- (void)fetchPaymentMethods {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.dropInContentView.state = BTDropInContentViewStateActivity;
    [self.client fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.paymentMethods = paymentMethods;
    } failure:^(NSError *error) {
        [self informDelegateDidFailWithError:error];
        self.dropInContentView.state = BTDropInContentViewStateForm;
    }];
}

- (void)setPaymentMethods:(NSArray *)paymentMethods {
    _paymentMethods = paymentMethods;

    if ([self.paymentMethods count] == 0) {
        self.selectedPaymentMethodIndex = NSNotFound;
        self.dropInContentView.state = BTDropInContentViewStateForm;
    } else {
        self.selectedPaymentMethodIndex = 0;
        self.dropInContentView.state = BTDropInContentViewStatePaymentMethodsOnFile;
    }
    [self updateValidity];
}

- (void)setSelectedPaymentMethodIndex:(NSInteger)selectedPaymentMethodIndex {
    _selectedPaymentMethodIndex = selectedPaymentMethodIndex;
    if (selectedPaymentMethodIndex == NSNotFound) {
        self.dropInContentView.state = BTDropInContentViewStateForm;
    } else {
        self.dropInContentView.state = BTDropInContentViewStatePaymentMethodsOnFile;
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

    if (!valid) {
        self.dropInContentView.ctaControl.alpha = 0.5f;
        self.dropInContentView.ctaControl.userInteractionEnabled = NO;
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        self.dropInContentView.ctaControl.alpha = 1.0f;
        self.dropInContentView.ctaControl.userInteractionEnabled = YES;
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
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

@end
