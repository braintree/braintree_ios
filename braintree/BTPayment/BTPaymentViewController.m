#import "BTPaymentViewController.h"
#import "BTPaymentFormView.h"
#import "BTPaymentActivityOverlayView.h"
#import "BTPaymentSectionHeaderView.h"
#import "BTDefines.h"

#import <QuartzCore/QuartzCore.h>

#define VTCARDVIEW_TAG 9

#define CELL_BACKGROUND_VIEW_TAG        10
#define CELL_BACKGROUND_VIEW_SHADOW_TAG 11
#define CELL_BORDER_COLOR               [[UIColor colorWithWhite:207/255.0f alpha:1] CGColor]

#define SUBMIT_BUTTON_TOP_PADDING       10
#define SUBMIT_BUTTON_NORMAL_TITLE_COLOR   [UIColor colorWithWhite:130/255.0f alpha:1]
#define SUBMIT_BUTTON_DISABLED_TITLE_COLOR [UIColor colorWithWhite:207/255.0f alpha:1]

#define SUBMIT_BUTTON_BORDER_COLOR           [UIColor colorWithWhite:194/255.0f alpha:1]

#define SUBMIT_BUTTON_DOWN_PRESS_GRADIENT_END_COLOR   [UIColor colorWithWhite:234/255.0f alpha:1]
#define SUBMIT_BUTTON_DISABLED_GRADIENT_START_COLOR   [UIColor colorWithWhite:245/255.0f alpha:1]
#define SUBMIT_BUTTON_DISABLED_GRADIENT_END_COLOR     [UIColor colorWithWhite:234/255.0f alpha:1]
#define SUBMIT_BUTTON_NORMAL_GRADIENT_START_COLOR     [UIColor colorWithWhite:245/255.0f alpha:1]
#define SUBMIT_BUTTON_NORMAL_GRADIENT_END_COLOR       [UIColor colorWithWhite:234/255.0f alpha:1]
#define SUBMIT_BUTTON_DOWN_PRESS_GRADIENT_START_COLOR [UIColor colorWithWhite:221/255.0f alpha:1]
#define SUBMIT_BUTTON_DOWN_PRESS_GRADIENT_END_COLOR   [UIColor colorWithWhite:234/255.0f alpha:1]

#define SUBMIT_BUTTON_HEIGHT 40
#define SUBMIT_BUTTON_GRADIENT_FRAME CGRectMake(0, 0, 568, SUBMIT_BUTTON_HEIGHT)

@interface BTPaymentViewController ()

@property (assign, nonatomic) BOOL venmoTouchEnabled;
@property (assign, nonatomic) BOOL hasPaymentMethods;

@property (strong, nonatomic) VTClient *client;
@property (strong, nonatomic) BTPaymentActivityOverlayView *paymentActivityOverlayView;
@property (strong, nonatomic) UIView *cellBackgroundView;
@property (strong, nonatomic) UIButton *submitButton;

@property (strong, nonatomic) UIView *disabledButtonGradientView;
@property (strong, nonatomic) UIView *normalButtonGradientView;
@property (strong, nonatomic) UIView *pressedButtonGradientView;

@property (nonatomic, strong) BTPaymentSectionHeaderView *paymentFormHeaderView;
@property (nonatomic, strong) BTPaymentSectionHeaderView *cardViewHeaderView;

@end

@implementation BTPaymentViewController

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
    _venmoTouchEnabled = hasVenmoTouchEnabled;
    _requestsZipInManualCardEntry = YES;
    return self;
}

#pragma mark - UIViewController

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // keyboard notifications
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundView = nil;
    if (!_cornerRadius) _cornerRadius = BT_DEFAULT_CORNER_RADIUS;
    if (!_viewBackgroundColor) _viewBackgroundColor = BT_DEFAULT_BACKGROUND_COLOR;
    [self setViewBackgroundColor:_viewBackgroundColor]; // Changes the display.

    Class class = NSClassFromString(@"VTClient");
    if (class) {
        _client = [class sharedVTClient];

        if (_venmoTouchEnabled) {
            if (!_client) {
                NSLog(@"Venmo Touch is enabled but VTClient has not yet been initialized. Please refer to VTClient.h to initialize it before displaying this BTPaymentViewController, or disable Venmo Touch when creating this BTPaymentViewController.");
            } else {
                _client.delegate = self;

                if (_client.paymentMethodOptionStatus == VTPaymentMethodOptionStatusYes) {
                    _hasPaymentMethods = YES;
                }

                // Register for keyboard notifications to autoscroll on BTPaymentFormView focus.
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:self.view.window];
            }
        }
    }

    // Create the payment form
    _paymentFormView = [BTPaymentFormView paymentFormView];
    _paymentFormView.delegate = self;
    _paymentFormView.requestsZip = _requestsZipInManualCardEntry;
    _paymentFormView.backgroundColor = [UIColor clearColor];

    // Create the checkbox view, if requested.
    if ([self showsVTCheckbox]) {
        // Set up the VTCheckboxView view
        _checkboxView = [_client checkboxView];
        [_checkboxView setOrigin:CGPointMake(-1, 0)]; // -1 for left-side alignment
        [_checkboxView setBackgroundColor:[UIColor clearColor]];
        [_checkboxView setTextColor:[UIColor grayColor]];
    }

    _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitButton.frame = CGRectMake(0, 0, 0, SUBMIT_BUTTON_HEIGHT);
    _submitButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_submitButton addSubview:self.normalButtonGradientView];
    [_submitButton bringSubviewToFront:_submitButton.titleLabel];
    _submitButton.layer.cornerRadius = _cornerRadius;
    _submitButton.layer.borderWidth  = 1;
    _submitButton.layer.borderColor  = [SUBMIT_BUTTON_BORDER_COLOR CGColor];
    _submitButton.clipsToBounds = YES;
    _submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [_submitButton setTitle:@"Submit New Card" forState:UIControlStateNormal];
    [_submitButton setTitleColor:SUBMIT_BUTTON_NORMAL_TITLE_COLOR forState:UIControlStateNormal];
    [_submitButton setTitleColor:SUBMIT_BUTTON_DISABLED_TITLE_COLOR forState:UIControlStateDisabled];
    [_submitButton addTarget:self action:@selector(submitCardInfo:)
           forControlEvents:UIControlEventTouchUpInside];

    [_submitButton addTarget:self action:@selector(submitButtonTouchDown)
           forControlEvents:UIControlEventTouchDown];
    [_submitButton addTarget:self action:@selector(submitButtonTouchDragExit)
           forControlEvents:UIControlEventTouchDragExit];
    [_submitButton addTarget:self action:@selector(submitButtonTouchDragEnter)
           forControlEvents:UIControlEventTouchDragEnter];

    UIView *topShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 1, _submitButton.frame.size.width, 1)];
    topShadow.backgroundColor = [UIColor colorWithWhite:1 alpha:.1];
    topShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_submitButton addSubview:topShadow];
    _submitButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    // If we know the user will have no option of seeing a VTCardView, then give firstResponder
    // to the BTPaymentFormView.
    if ((_venmoTouchEnabled && _client &&
        _client.paymentMethodOptionStatus == VTPaymentMethodOptionStatusNo)
        || !_venmoTouchEnabled
        || !_client) {
        [_paymentFormView.cardNumberTextField becomeFirstResponder];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardDidShow:(NSNotification *)notification {
    // If Use Card button is showing, auto-scroll to bottom cell.
    if ([self numberOfSectionsInTableView:self.tableView] == 2) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:1]-1)
                                                    inSection:1];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UIScrollView

// Hide keyboard when the user scrolls
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    UITextField *firstResponder = nil;
    if ([_paymentFormView.cardNumberTextField isFirstResponder]) firstResponder = _paymentFormView.cardNumberTextField;
    else if ([_paymentFormView.monthYearTextField isFirstResponder]) firstResponder = _paymentFormView.monthYearTextField;
    else if ([_paymentFormView.cvvTextField isFirstResponder]) firstResponder = _paymentFormView.cvvTextField;
    else if ([_paymentFormView.zipTextField isFirstResponder]) firstResponder = _paymentFormView.zipTextField;
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
}

#pragma mark - Submit button states

- (void)submitButtonTouchUpInside {
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
    [_submitButton addSubview:to];
    [_submitButton bringSubviewToFront:_submitButton.titleLabel];
}

#pragma mark - BTPaymentViewController public methods

- (void)prepareForDismissal {
    [_paymentActivityOverlayView dismissAnimated:YES];
}

- (void)showErrorWithTitle:(NSString *)title message:(NSString *)message {
    [_paymentActivityOverlayView dismissAnimated:NO];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark - BTPaymentViewController private methods

- (BOOL)showsVTCheckbox {
    return (self.venmoTouchEnabled && self.client && self.client.liveStatus != VTLiveStatusNo);
}

- (void)submitCardInfo:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(paymentViewController:didSubmitCardWithInfo:andCardInfoEncrypted:)]) {
        if (!_paymentActivityOverlayView) {
            _paymentActivityOverlayView = [BTPaymentActivityOverlayView sharedOverlayView];
        }
        [_paymentActivityOverlayView show];

        // Get card info dictionary from the payment form.
        NSDictionary *cardInfo = [_paymentFormView cardEntry];
        NSDictionary *cardInfoEncrypted;
        if (_venmoTouchEnabled && !_client) {
            NSLog(@"Venmo Touch is enabled but VTClient has not yet been initialized, so the encrypted card information can not be returned to you. Please refer to VTClient.h to initialize it before displaying this BTPaymentViewController, or disable Venmo Touch when creating this BTPaymentViewController.");
        } else if ([_client braintreeClientSideEncryptionKey]) {
            // If VTClient has a client side encryption key, return encrypted card info.
            cardInfoEncrypted = [_client encryptedCardDataAndVenmoSDKSessionWithCardDictionary:cardInfo];
        }

        [_delegate paymentViewController:self didSubmitCardWithInfo:cardInfo andCardInfoEncrypted:cardInfoEncrypted];
    }
    [self submitButtonTouchUpInside];
}

- (void)paymentMethodFound {
    if (_hasPaymentMethods) {
        // This case may happen when the user closes the app when viewing the payment form.
        // Open re-opening, [client refresh] will trigger (if no modal is visible) and the
        // cardView would not need animate in again if it already exists.
        _cardView = nil;
        [self.tableView reloadData];
    } else {
        _hasPaymentMethods = YES;

        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationAutomatic];

        [self performSelector:@selector(reloadTitle) withObject:nil afterDelay:.3];
    }
}

- (void)hideVTCardViewSection {
    if ([self.tableView numberOfSections] == 2) {
        self.hasPaymentMethods = NO;
        self.cardView = nil;
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
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:(_hasPaymentMethods ? 1 : 0)]
//                  withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_hasPaymentMethods && indexPath.section == 0) {
        // VTCardView
        return 74 - 6; //-6 to get nice-sized padding between VTCardView and "Submit New Card" button
    } else if (indexPath.row == 0) {
        // BTPaymentFormView
        return 40;
    } else if (indexPath.row == 1) {
        // VTCheckbox (if available) and Submit button
        CGFloat height = ([self showsVTCheckbox] ? _checkboxView.frame.size.height : SUBMIT_BUTTON_TOP_PADDING)
                          + _submitButton.frame.size.height;
        return height;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0 ? 40 : 30);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (_hasPaymentMethods ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_hasPaymentMethods && section == 0) {
        // VTCardView
        return 1;
    } else {
        // BTPaymentFormView & VTCheckboxView + submit button
        return 2;
    }
}

// Don't use "tableView:titleForHeaderInSection:" because titles don't auto-update when
// number of sections update.
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 && _hasPaymentMethods) {
        // Section for the Use Card button.
        return self.cardViewHeaderView;
    } else {
        // Section that displays the payment form view. Must change the section title accordingly.
        [self.paymentFormHeaderView setIsTopSectionHeader:!_hasPaymentMethods];
        [self.paymentFormHeaderView setTitleText:(_hasPaymentMethods ? @"Or, Add a New Card" : @"Add a New Card")];
        return self.paymentFormHeaderView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *UseCardCellIdentifier               = @"UseCardCell";
    static NSString *PaymentFormViewCellIdentifier       = @"PaymentFormViewCell";
    static NSString *PaymentFormViewFooterCellIdentifier = @"PaymentFormViewFooterCell";

    NSString *currentCellIdentifier;
    if (_hasPaymentMethods && indexPath.section == 0) {
        currentCellIdentifier = UseCardCellIdentifier;
    } else if (indexPath.row == 0) {
        currentCellIdentifier = PaymentFormViewCellIdentifier;
    } else {
        currentCellIdentifier = PaymentFormViewFooterCellIdentifier;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UseCardCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:currentCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if ([currentCellIdentifier isEqualToString:PaymentFormViewCellIdentifier]) {
            [self setUpPaymentFormViewForCell:cell];
        }
    }
    
    if ([currentCellIdentifier isEqualToString:UseCardCellIdentifier]) {
        [self setUpCardViewForCell:cell];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_hasPaymentMethods && indexPath.section == 0) {
        // Venmo Touch row || checkbox + submit button row
        cell.backgroundView = nil;
    }
    else if (indexPath.row == 0) {
        // Customize the cell background view
        if (cell.backgroundView.tag != CELL_BACKGROUND_VIEW_TAG) {
            _cellBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            _cellBackgroundView.backgroundColor = [UIColor whiteColor];
            _cellBackgroundView.tag = CELL_BACKGROUND_VIEW_TAG;
            _cellBackgroundView.layer.cornerRadius  = _cornerRadius;
            _cellBackgroundView.layer.borderColor   = CELL_BORDER_COLOR;
            _cellBackgroundView.layer.borderWidth   = 1;
            _cellBackgroundView.layer.shadowRadius  = 1;
            _cellBackgroundView.layer.shadowOpacity = 1;
            _cellBackgroundView.layer.shadowColor   = [[UIColor whiteColor] CGColor];
            _cellBackgroundView.layer.shadowOffset  = CGSizeMake(0, 1);
            _cellBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            UIView *topShadowView = [[UIView alloc] initWithFrame:CGRectMake(3, 1, _cellBackgroundView.frame.size.width, 1)];
            topShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            topShadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
            topShadowView.tag = CELL_BACKGROUND_VIEW_SHADOW_TAG;
            [_cellBackgroundView addSubview:topShadowView];
            [self adjustCellBackgroundViewShadow];

            cell.backgroundView = nil;
            cell.backgroundView = _cellBackgroundView;

            [self setUpPaymentFormViewForCell:cell];
        }
    } else {
        cell.backgroundView = nil;
        CGFloat contentViewWidth = cell.contentView.frame.size.width;

        [_checkboxView setWidth:contentViewWidth];
        [cell.contentView addSubview:_checkboxView];

        _submitButton.frame = CGRectMake(0, ([self showsVTCheckbox] ? _checkboxView.frame.size.height :SUBMIT_BUTTON_TOP_PADDING),
                                         contentViewWidth, SUBMIT_BUTTON_HEIGHT);
        [cell.contentView addSubview:_submitButton];
    }
}

- (void)adjustCellBackgroundViewShadow {
    // Set the background cell's top shadow width.
    UIView *topShadowView = [_cellBackgroundView viewWithTag:CELL_BACKGROUND_VIEW_SHADOW_TAG];
    CGFloat topShadowBuffer = ceilf(_cornerRadius/2.0f + (_cornerRadius > 10 ? 1 : 0)); //(_cornerRadius/2 - 1)
    CGRect topShadowFrame = CGRectMake(topShadowBuffer, 1, _cellBackgroundView.frame.size.width - topShadowBuffer*2, 1);
    topShadowView.frame = topShadowFrame;
}

- (void)setUpCardViewForCell:(UITableViewCell *)cell {
    if (!_cardView) {
        _cardView = [_client cardView];
        _cardView.tag = VTCARDVIEW_TAG;
        // Set styling defaults if they were set before cardView was initialized
        if (_cornerRadius)                _cardView.cornerRadius           = _cornerRadius;
        if (_vtCardViewBackgroundColor)   self.vtCardViewBackgroundColor   = _vtCardViewBackgroundColor;
        if (_vtCardViewTitleFont)         self.vtCardViewTitleFont         = _vtCardViewTitleFont;
        if (_vtCardViewInfoButtonFont)    self.vtCardViewInfoButtonFont    = _vtCardViewInfoButtonFont;
    }
    
    if (_cardView && cell && ![cell.contentView viewWithTag:VTCARDVIEW_TAG]) {
        [_cardView setOrigin:CGPointMake(0, 0)];
        [_cardView setBackgroundColor:[UIColor clearColor]];
        [_cardView setWidth:cell.contentView.frame.size.width];
        [cell.contentView addSubview:_cardView];
    }
}

- (void)setUpPaymentFormViewForCell:(UITableViewCell *)cell {
    [_paymentFormView removeFromSuperview];
    [cell.contentView addSubview:_paymentFormView];
}


#pragma mark - BTPaymentFormViewDelegate

- (void)paymentFormView:(BTPaymentFormView *)paymentFormView didModifyCardInformationWithValidity:(BOOL)isValid {
    _submitButton.enabled = isValid;
    _submitButton.layer.borderColor = [SUBMIT_BUTTON_BORDER_COLOR CGColor];
    if (isValid) {
        [self swapSubmitButtonGradientViewTo:self.normalButtonGradientView from:self.disabledButtonGradientView];
    } else {
        [self swapSubmitButtonGradientViewTo:self.disabledButtonGradientView from:self.normalButtonGradientView];
    }
}

#pragma mark - VTClientDelegate

- (void)client:(VTClient *)client didReceivePaymentMethodOptionStatus:(VTPaymentMethodOptionStatus)paymentMethodOptionStatus {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"loading finished: %i", paymentMethodOptionStatus);
    if (paymentMethodOptionStatus == VTPaymentMethodOptionStatusYes) {
        // Force tableview to reloadData, which renders VTCardView
        NSLog(@"payment method on file");
        [self paymentMethodFound];
    } else if (_hasPaymentMethods && paymentMethodOptionStatus != VTPaymentMethodOptionStatusYes) {
        _hasPaymentMethods = NO;
        [self.tableView reloadData];
    }
}

- (void)client:(VTClient *)client didFinishLoadingLiveStatus:(VTLiveStatus)liveStatus {
    NSLog(@"didFinishLoadingLiveStatus: %i", liveStatus);
}

- (void)client:(VTClient *)client approvedPaymentMethodWithCode:(NSString *)paymentMethodCode {
    // Return it to the delegate
    if ([_delegate respondsToSelector:
         @selector(paymentViewController:didAuthorizeCardWithPaymentMethodCode:)]) {
        if (!_paymentActivityOverlayView) {
            _paymentActivityOverlayView = [BTPaymentActivityOverlayView sharedOverlayView];
            [_paymentActivityOverlayView show];
        }

        [_delegate paymentViewController:self didAuthorizeCardWithPaymentMethodCode:paymentMethodCode];
    }
}

- (void)clientWillReceivePaymentMethodOptionStatus:(VTClient *)client {
    [self hideVTCardViewSection];
}

- (void)clientDidLogout:(VTClient *)client {
    [self hideVTCardViewSection];
    
    // Hack to solve https://app.asana.com/0/1793436647059/7290336768294.
    [self.tableView reloadData];
}

#pragma mark - UI Customization

- (void)setRequestsZipInManualCardEntry:(BOOL)requestsZipInManualCardEntry {
    _requestsZipInManualCardEntry =
    _paymentFormView.requestsZip   = requestsZipInManualCardEntry;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (!(0 <= cornerRadius && cornerRadius <= 15)) {
        return;
    } else if (cornerRadius == 0) {
        // This is a hack.
        cornerRadius = 1;
    }

    _cornerRadius = cornerRadius;
    _cardView.cornerRadius =
    _cellBackgroundView.layer.cornerRadius  =
    _submitButton.layer.cornerRadius  =
    _cornerRadius;

    [self adjustCellBackgroundViewShadow];
}

- (void)setViewBackgroundColor:(UIColor *)color {
    _viewBackgroundColor =
    self.tableView.backgroundColor = color;
    self.paymentFormHeaderView.backgroundColor = color;
    self.cardViewHeaderView.backgroundColor = color;
}

- (void)setVtCardViewBackgroundColor:(UIColor *)vtCardViewBackgroundColor {
    _vtCardViewBackgroundColor =
    _cardView.useCardButtonBackgroundColor = vtCardViewBackgroundColor;
}

- (void)setVtCardViewTitleFont:(UIFont *)vtCardViewTitleFont {
    _vtCardViewTitleFont =
    _cardView.useCardButtonTitleFont = vtCardViewTitleFont;
}

- (void)setVtCardViewInfoButtonFont:(UIFont *)vtCardViewInfoButtonFont {
    _vtCardViewInfoButtonFont =
    _cardView.infoButtonFont = vtCardViewInfoButtonFont;
}

#pragma mark - Section Headers

- (UIView *)paymentFormHeaderView {
    if (!_paymentFormHeaderView) {
        _paymentFormHeaderView = [[BTPaymentSectionHeaderView alloc] initWithFrame:
                                  CGRectMake(0, 0, 320, BT_PAYMENT_SECTION_HEADER_VIEW_HEIGHT)];
    }
    return _paymentFormHeaderView;
}

- (UIView *)cardViewHeaderView {
    if (!_cardViewHeaderView) {
        _cardViewHeaderView = [[BTPaymentSectionHeaderView alloc] initWithFrame:
                               CGRectMake(0, 0, 320, BT_PAYMENT_SECTION_HEADER_VIEW_HEIGHT)];
        [self.cardViewHeaderView setTitleText:@"Use a Saved Card"];
    }
    return _cardViewHeaderView;
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
