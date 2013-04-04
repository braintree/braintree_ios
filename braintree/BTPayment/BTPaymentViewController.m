#import "BTPaymentViewController.h"
#import "BTPaymentFormView.h"
#import "BTPaymentActivityOverlayView.h"

#import <QuartzCore/QuartzCore.h>

#define BT_DEFAULT_CORNER_RADIUS 4
#define BT_APP_COLOR             [UIColor clearColor]
#define BT_APP_TEXT_COLOR        [UIColor colorWithWhite:85/255.0f alpha:1]

#define CELL_BACKGROUND_VIEW_TAG        10
#define CELL_BACKGROUND_VIEW_SHADOW_TAG 11
#define CELL_BORDER_COLOR               [[UIColor colorWithWhite:207/255.0f alpha:1] CGColor]

#define SUBMIT_BUTTON_NORMAL_TITLE_COLOR   [UIColor colorWithWhite:130/255.0f alpha:1]
#define SUBMIT_BUTTON_DISABLED_TITLE_COLOR [UIColor colorWithWhite:207/255.0f alpha:1]

#define SUBMIT_BUTTON_BORDER_DISABLED_COLOR           [UIColor colorWithWhite:194/255.0f alpha:1]
#define SUBMIT_BUTTON_BORDER_ENABLED_COLOR            [UIColor colorWithWhite:163/255.0f alpha:1]

#define SUBMIT_BUTTON_DOWN_PRESS_GRADIENT_END_COLOR   [UIColor colorWithWhite:234/255.0f alpha:1]
#define SUBMIT_BUTTON_DISABLED_GRADIENT_START_COLOR   [UIColor colorWithWhite:245/255.0f alpha:1]
#define SUBMIT_BUTTON_DISABLED_GRADIENT_END_COLOR     [UIColor colorWithWhite:234/255.0f alpha:1]
#define SUBMIT_BUTTON_NORMAL_GRADIENT_START_COLOR     [UIColor colorWithWhite:245/255.0f alpha:1]
#define SUBMIT_BUTTON_NORMAL_GRADIENT_END_COLOR       [UIColor colorWithWhite:234/255.0f alpha:1]
#define SUBMIT_BUTTON_DOWN_PRESS_GRADIENT_START_COLOR [UIColor colorWithWhite:221/255.0f alpha:1]
#define SUBMIT_BUTTON_DOWN_PRESS_GRADIENT_END_COLOR   [UIColor colorWithWhite:234/255.0f alpha:1]

#define SUBMIT_BUTTON_GRADIENT_FRAME CGRectMake(0, 0, submitButton.frame.size.width, submitButton.frame.size.height)

@interface BTPaymentViewController ()

@property (assign, nonatomic) BOOL venmoTouchEnabled;
@property (assign, nonatomic) BOOL hasPaymentMethods;

@property (strong, nonatomic) VTClient *client;
@property (strong, nonatomic) BTPaymentActivityOverlayView *paymentActivityOverlayView;
@property (strong, nonatomic) UIView *cellBackgroundView;
@property (strong, nonatomic) UIView *paymentFormFooterView;
@property (strong, nonatomic) UIButton *submitButton;

@property (strong, nonatomic) UIView *disabledButtonGradientView;
@property (strong, nonatomic) UIView *normalButtonGradientView;
@property (strong, nonatomic) UIView *pressedButtonGradientView;

@end

@implementation BTPaymentViewController

// public
@synthesize delegate;

// private
@synthesize venmoTouchEnabled;
@synthesize hasPaymentMethods;
@synthesize client;
@synthesize paymentFormView;
@synthesize cardView;
@synthesize checkboxCardView;
@synthesize paymentActivityOverlayView;
@synthesize cellBackgroundView;
@synthesize paymentFormFooterView;
@synthesize submitButton;

+ (id)paymentViewControllerWithVenmoTouchEnabled:(BOOL)hasVenmoTouchEnabled {
    BTPaymentViewController *paymentViewController =
    [[BTPaymentViewController alloc] initWithStyle:UITableViewStyleGrouped
                                   hasVenmoTouchEnabled:hasVenmoTouchEnabled];
    return paymentViewController;
}

#pragma mark - UITableViewController

- (id)initWithStyle:(UITableViewStyle)style hasVenmoTouchEnabled:(BOOL)hasVenmoTouchEnabled {
    self = [super initWithStyle:style];
    if (!self) {
        return nil;
    }

    self.title = @"Payment";
    self.venmoTouchEnabled = hasVenmoTouchEnabled;
    _requestsZipInManualCardEntry = YES;
    return self;
}

#pragma mark - UIViewController

- (void)viewDidUnload {

    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundView = nil;
    if (!_cornerRadius) _cornerRadius = BT_DEFAULT_CORNER_RADIUS;
    if (!_viewBackgroundColor) _viewBackgroundColor = [UIColor colorWithWhite:238/255.0f alpha:1];
    self.viewBackgroundColor = _viewBackgroundColor; // Changes the display.

    if (self.venmoTouchEnabled) {
        Class class = NSClassFromString(@"VTClient");
        if (class) {
            self.client = [class sharedClient];
            self.client.delegate = self;

            if (client.paymentMethodOptionStatus == VTPaymentMethodOptionStatusYes) {
                hasPaymentMethods = YES;
            }
        }
    }

    // Create the payment form
    self.paymentFormView = [BTPaymentFormView paymentFormView];
    self.paymentFormView.delegate = self;
    self.paymentFormView.requestsZip = _requestsZipInManualCardEntry;
    self.paymentFormView.backgroundColor = [UIColor clearColor];

    // Section footer view to display the VTCheckboxView view and manual card's submit button
    paymentFormFooterView = [[UIView alloc] initWithFrame:
                           CGRectMake(0, 0, self.view.frame.size.width,
                                      (self.venmoTouchEnabled && self.client ? 120 : 60))];
    paymentFormFooterView.backgroundColor = [UIColor clearColor];

    if (self.venmoTouchEnabled && self.client) {
        // Set up the VTCheckboxView view
        checkboxCardView = [self.client checkboxView];
        [checkboxCardView setOrigin:CGPointMake(9, 0)]; // 10-1 for left-side alignment
        [checkboxCardView setWidth:300];
        [checkboxCardView setBackgroundColor:[UIColor clearColor]];
        [checkboxCardView setTextColor:[UIColor grayColor]];
        [paymentFormFooterView addSubview:checkboxCardView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideVTCardViewSection) name:UIApplicationWillResignActiveNotification object:nil];
    }

    submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(10, paymentFormFooterView.frame.size.height - 50, 300, 40);
    submitButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [submitButton addSubview:self.normalButtonGradientView];
    [submitButton bringSubviewToFront:submitButton.titleLabel];
    submitButton.layer.cornerRadius = _cornerRadius;
    submitButton.layer.borderWidth  = 1;
    submitButton.layer.borderColor  = [SUBMIT_BUTTON_BORDER_DISABLED_COLOR CGColor];
    submitButton.clipsToBounds = YES;
    submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [submitButton setTitle:@"Submit New Card" forState:UIControlStateNormal];
    [submitButton setTitleColor:SUBMIT_BUTTON_NORMAL_TITLE_COLOR
                       forState:UIControlStateNormal];
    [submitButton setTitleColor:SUBMIT_BUTTON_DISABLED_TITLE_COLOR
                       forState:UIControlStateDisabled];
    [submitButton addTarget:self action:@selector(submitCardInfo:)
           forControlEvents:UIControlEventTouchUpInside];

    [submitButton addTarget:self action:@selector(submitButtonTouchDown)
           forControlEvents:UIControlEventTouchDown];
    [submitButton addTarget:self action:@selector(submitButtonTouchDragExit)
           forControlEvents:UIControlEventTouchDragExit];
    [submitButton addTarget:self action:@selector(submitButtonTouchDragEnter)
           forControlEvents:UIControlEventTouchDragEnter];

    UIView *topShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 1, submitButton.frame.size.width, 1)];
    topShadow.backgroundColor = [UIColor colorWithWhite:1 alpha:.1];
    topShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [submitButton addSubview:topShadow];

    [paymentFormFooterView addSubview:submitButton];
    submitButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    // If we know the user will have no option of seeing a VTCardView, then give firstResponder
    // to the BTPaymentFormView.
    if ((self.venmoTouchEnabled && self.client &&
        self.client.paymentMethodOptionStatus == VTPaymentMethodOptionStatusNo)
        || !self.venmoTouchEnabled
        || !self.client) {
        [paymentFormView.cardNumberTextField becomeFirstResponder];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIScrollView

// Hide keyboard when the user scrolls
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    UITextField *firstResponder;
    if ([paymentFormView.cardNumberTextField isFirstResponder]) firstResponder = paymentFormView.cardNumberTextField;
    else if ([paymentFormView.monthYearTextField isFirstResponder]) firstResponder = paymentFormView.monthYearTextField;
    else if ([paymentFormView.cvvTextField isFirstResponder]) firstResponder = paymentFormView.cvvTextField;
    else if ([paymentFormView.zipTextField isFirstResponder]) firstResponder = paymentFormView.zipTextField;
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
}

#pragma mark - Submit button states

- (void)submitButtonTouchUpInside {
//    submitButton.layer.borderColor  = [SUBMIT_BUTTON_BORDER_DISABLED_COLOR CGColor];
    [self swapSubmitButtonGradientViewTo:self.normalButtonGradientView from:self.pressedButtonGradientView];
}

- (void)submitButtonTouchDown {
    [self swapSubmitButtonGradientViewTo:self.pressedButtonGradientView from:self.normalButtonGradientView];
}

- (void)submitButtonTouchDragExit {
    [self swapSubmitButtonGradientViewTo:self.normalButtonGradientView from:self.pressedButtonGradientView];
}

- (void)submitButtonTouchDragEnter {
    [self swapSubmitButtonGradientViewTo:self.pressedButtonGradientView from:self.normalButtonGradientView];
}

- (void)swapSubmitButtonGradientViewTo:(UIView *)to from:(UIView *)from {
    [from removeFromSuperview];
    [submitButton addSubview:to];
    [submitButton bringSubviewToFront:submitButton.titleLabel];
}

#pragma mark - BTPaymentViewController private methods

- (void)prepareForDismissal {
    [paymentActivityOverlayView dismissAnimated:YES];
}

- (void)showErrorWithTitle:(NSString *)title message:(NSString *)message {
    [paymentActivityOverlayView dismissAnimated:NO];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark - BTPaymentViewController private methods

- (void)submitCardInfo:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(paymentViewController:didSubmitCardWithInfo:andCardInfoEncrypted:)]) {
        if (!paymentActivityOverlayView) {
            paymentActivityOverlayView = [BTPaymentActivityOverlayView sharedOverlayView];
        }
        [paymentActivityOverlayView show];

        // Get card info dictionary from the payment form.
        NSDictionary *cardInfo = [self.paymentFormView cardEntry];
        NSDictionary *cardInfoEncrypted;
        if (client && venmoTouchEnabled) {
            // If Venmo Touch, encrypt card info with Braintree's CSE key
            cardInfoEncrypted = [client encryptedCardDataAndVenmoSDKSessionWithCardDictionary:cardInfo];
        }

        [self.delegate paymentViewController:self didSubmitCardWithInfo:cardInfo andCardInfoEncrypted:cardInfoEncrypted];
    }
    [self submitButtonTouchUpInside];
}

- (void)paymentMethodFound {
    if (hasPaymentMethods) {
        // This case may happen when the user closes the app when viewing the payment form.
        // Open re-opening, [client refresh] will trigger (if no modal is visible) and the
        // cardView would not need animate in again if it already exists.
        cardView = nil;
        [self.tableView reloadData];
    } else {
        hasPaymentMethods = YES;

        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationAutomatic];

        [self performSelector:@selector(reloadTitle) withObject:nil afterDelay:.3];
    }
}

- (void)hideVTCardViewSection {
    if ([self.tableView numberOfSections] == 2) {
        hasPaymentMethods = NO;
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        [self performSelector:@selector(reloadTitle) withObject:nil afterDelay:.3];
    }
}

- (void)reloadTitle {
    [self.tableView reloadData];

    // webview is causing a crash when it exists in a table footer view and you reload a particular section
    // look like a bug with Apple.
    // http://stackoverflow.com/questions/11626572/uiwebview-as-view-for-footer-in-section-for-tableview-strange-crash-crash-log
    //    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:(hasPaymentMethods ? 1 : 0)]
    //                  withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 81 = height for VTCardView, 40 = height of enter card manually cell
    return (hasPaymentMethods && indexPath.section == 0 ? 74 : 40);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (hasPaymentMethods && section == 0) {
        // VTCardView
        return 0.5f;
    } else {
        // BTPaymentFormView
        return (self.venmoTouchEnabled ? 120 : 50);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    // VTCardView has no footer view.
    // Payment form view has submit button and perhaps VTCheckboxView
    return (hasPaymentMethods && section == 0 ? nil : paymentFormFooterView);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (hasPaymentMethods ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Don't use "tableView:titleForHeaderInSection:" because titles don't auto-update when
// number of sections update.
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:
                    CGRectMake(0, 0, 320, 40)];
    view.backgroundColor = BT_APP_COLOR;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
    titleLabel.backgroundColor = BT_APP_COLOR;
    titleLabel.textColor = BT_APP_TEXT_COLOR;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    [view addSubview:titleLabel];
    
    if (hasPaymentMethods && section == 0) {
        titleLabel.text = @"Use a Saved Card";
    } else {
        titleLabel.text = (hasPaymentMethods ? @"Or, Add a New Card" : @"Add a New Card");
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *UseCardCell         = @"UseCardCell";
    static NSString *PaymentFormViewCell = @"PaymentFormViewCell";

    NSString *currentCellIdentifier;
    if (hasPaymentMethods && indexPath.section == 0) {
        currentCellIdentifier = UseCardCell;
    } else {
        currentCellIdentifier = PaymentFormViewCell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UseCardCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:currentCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if ([currentCellIdentifier isEqualToString:PaymentFormViewCell]) {
            [self setUpPaymentFormViewForCell:cell];
        }
    }

    if ([currentCellIdentifier isEqualToString:UseCardCell]) {
        [self setUpCardViewForCell:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (hasPaymentMethods && indexPath.section == 0) {
        // Venmo Touch row
        cell.backgroundView = nil;
    }
    else {
        // Customize the cell background view
        if (cell.backgroundView.tag != CELL_BACKGROUND_VIEW_TAG) {
            cellBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cellBackgroundView.backgroundColor = [UIColor whiteColor];
            cellBackgroundView.tag = CELL_BACKGROUND_VIEW_TAG;
            cellBackgroundView.layer.cornerRadius  = _cornerRadius;
            cellBackgroundView.layer.borderColor   = CELL_BORDER_COLOR;
            cellBackgroundView.layer.borderWidth   = 1;
            cellBackgroundView.layer.shadowRadius  = 1;
            cellBackgroundView.layer.shadowOpacity = 1;
            cellBackgroundView.layer.shadowColor   = [[UIColor whiteColor] CGColor];
            cellBackgroundView.layer.shadowOffset  = CGSizeMake(0, 1);
            cellBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            UIView *topShadowView = [[UIView alloc] initWithFrame:CGRectMake(3, 1, cellBackgroundView.frame.size.width, 1)];
            topShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            topShadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
            topShadowView.tag = CELL_BACKGROUND_VIEW_SHADOW_TAG;
            [cellBackgroundView addSubview:topShadowView];
            [self adjustCellBackgroundViewShadow];

            cell.backgroundView = nil;
            cell.backgroundView = cellBackgroundView;

            [self setUpPaymentFormViewForCell:cell];
        }
    }
}

- (void)adjustCellBackgroundViewShadow {
    // Set the background cell's top shadow width.
    UIView *topShadowView = [cellBackgroundView viewWithTag:CELL_BACKGROUND_VIEW_SHADOW_TAG];
    CGFloat topShadowBuffer = ceilf(_cornerRadius/2.0f + (_cornerRadius > 10 ? 1 : 0)); //(_cornerRadius/2 - 1)
    CGRect topShadowFrame = CGRectMake(topShadowBuffer, 1, cellBackgroundView.frame.size.width - topShadowBuffer*2, 1);
    topShadowView.frame = topShadowFrame;
}

- (void)setUpCardViewForCell:(UITableViewCell *)cell {
    if (!cardView) {
        cardView = [self.client cardView];
        // Set styling defaults if they were set before cardView was initialized
        if (_cornerRadius)                self.cardView.cornerRadius       = _cornerRadius;
        if (_vtCardViewBackgroundColor)   self.vtCardViewBackgroundColor   = _vtCardViewBackgroundColor;
        if (_vtCardViewTitleFont)         self.vtCardViewTitleFont         = _vtCardViewTitleFont;
        if (_vtCardViewInfoButtonFont)    self.vtCardViewInfoButtonFont    = _vtCardViewInfoButtonFont;
    }
    
    if (cardView && cell) {
        [cardView setOrigin:CGPointMake(0, 0)];
        [cardView setBackgroundColor:[UIColor clearColor]];
        [cardView setWidth:300];
        [cell.contentView addSubview:cardView];
    }
}

- (void)setUpPaymentFormViewForCell:(UITableViewCell *)cell {
    [paymentFormView removeFromSuperview];
    [cell.contentView addSubview:paymentFormView];
}


#pragma mark - BTPaymentFormViewDelegate

- (void)paymentFormView:(BTPaymentFormView *)paymentFormView didModifyCardInformationWithValidity:(BOOL)isValid {
    submitButton.enabled = isValid;
    submitButton.layer.borderColor  = (isValid ? [SUBMIT_BUTTON_BORDER_ENABLED_COLOR CGColor] : [SUBMIT_BUTTON_BORDER_DISABLED_COLOR CGColor]);
}

#pragma mark - VTClientDelegate

- (void)client:(VTClient *)client didReceivePaymentMethodOptionStatus:(VTPaymentMethodOptionStatus)paymentMethodOptionStatus {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"loading finished: %i", paymentMethodOptionStatus);
    if (paymentMethodOptionStatus == VTPaymentMethodOptionStatusYes) {
        // Force tableview to reloadData, which renders VTCardView
        NSLog(@"payment method on file");
        [self paymentMethodFound];
    } else if (hasPaymentMethods && paymentMethodOptionStatus != VTPaymentMethodOptionStatusYes) {
        hasPaymentMethods = NO;
        [self.tableView reloadData];
    }
}

- (void)client:(VTClient *)client didFinishLoadingLiveStatus:(VTLiveStatus)liveStatus {
    NSLog(@"didFinishLoadingLiveStatus: %i", liveStatus);
}

- (void)client:(VTClient *)client approvedPaymentMethodWithCode:(NSString *)paymentMethodCode {
    // Return it to the delegate
    if ([self.delegate respondsToSelector:
         @selector(paymentViewController:didAuthorizeCardWithPaymentMethodCode:)]) {
        if (!paymentActivityOverlayView) {
            paymentActivityOverlayView = [BTPaymentActivityOverlayView sharedOverlayView];
            [paymentActivityOverlayView show];
        }

        [delegate paymentViewController:self didAuthorizeCardWithPaymentMethodCode:paymentMethodCode];
    }
}

- (void)clientDidLogout:(VTClient *)client {
    [self hideVTCardViewSection];
}

#pragma mark - UI Customization

- (void)setRequestsZipInManualCardEntry:(BOOL)requestsZipInManualCardEntry {
    _requestsZipInManualCardEntry =
    paymentFormView.requestsZip   = requestsZipInManualCardEntry;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (!(0 <= cornerRadius && cornerRadius <= 15)) {
        return;
    } else if (cornerRadius == 0) {
        // This is a hack.
        cornerRadius = 1;
    }

    _cornerRadius = cornerRadius;
    cardView.cornerRadius =
    cellBackgroundView.layer.cornerRadius  =
    submitButton.layer.cornerRadius  =
    _cornerRadius;

    [self adjustCellBackgroundViewShadow];
}

- (void)setViewBackgroundColor:(UIColor *)color {
    _viewBackgroundColor =
    self.tableView.backgroundColor = color;
}

- (void)setVtCardViewBackgroundColor:(UIColor *)vtCardViewBackgroundColor {
    _vtCardViewBackgroundColor =
    self.cardView.useCardButtonBackgroundColor = vtCardViewBackgroundColor;
}

- (void)setVtCardViewTitleFont:(UIFont *)vtCardViewTitleFont {
    _vtCardViewTitleFont =
    self.cardView.useCardButtonTitleFont = vtCardViewTitleFont;
}

- (void)setVtCardViewInfoButtonFont:(UIFont *)vtCardViewInfoButtonFont {
    _vtCardViewInfoButtonFont =
    self.cardView.infoButtonFont = vtCardViewInfoButtonFont;
}

#pragma mark - UIButton Gradients

- (UIView *)disabledButtonGradientView {
    if (!_disabledButtonGradientView) {
        _disabledButtonGradientView = [[UIView alloc] initWithFrame:SUBMIT_BUTTON_GRADIENT_FRAME];
        _disabledButtonGradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _disabledButtonGradientView.userInteractionEnabled = NO;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _disabledButtonGradientView.bounds;
        gradient.colors = @[(id)[SUBMIT_BUTTON_DISABLED_GRADIENT_START_COLOR CGColor],
                            (id)[SUBMIT_BUTTON_DISABLED_GRADIENT_END_COLOR CGColor]];
        [_disabledButtonGradientView.layer insertSublayer:gradient atIndex:0];
    }
    return _disabledButtonGradientView;
}

- (UIView *)normalButtonGradientView {
    if (!_normalButtonGradientView) {
        _normalButtonGradientView = [[UIView alloc] initWithFrame:SUBMIT_BUTTON_GRADIENT_FRAME];
        _normalButtonGradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _normalButtonGradientView.userInteractionEnabled = NO;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _normalButtonGradientView.bounds;
        gradient.colors = @[(id)[SUBMIT_BUTTON_NORMAL_GRADIENT_START_COLOR CGColor],
                            (id)[SUBMIT_BUTTON_NORMAL_GRADIENT_END_COLOR CGColor]];
        [_normalButtonGradientView.layer insertSublayer:gradient atIndex:0];
    }
    return _normalButtonGradientView;
}

- (UIView *)pressedButtonGradientView {
    if (!_pressedButtonGradientView) {
        _pressedButtonGradientView = [[UIView alloc] initWithFrame:SUBMIT_BUTTON_GRADIENT_FRAME];
        _pressedButtonGradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pressedButtonGradientView.userInteractionEnabled = NO;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = _pressedButtonGradientView.bounds;
        gradient.colors = @[(id)[SUBMIT_BUTTON_DOWN_PRESS_GRADIENT_START_COLOR CGColor],
                            (id)[SUBMIT_BUTTON_DOWN_PRESS_GRADIENT_END_COLOR CGColor]];
        [_pressedButtonGradientView.layer insertSublayer:gradient atIndex:0];
    }
    return _pressedButtonGradientView;
}

@end
