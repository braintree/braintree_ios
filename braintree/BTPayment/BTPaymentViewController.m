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

#define CELL_SIDE_PADDING (BT_IS_IOS7_OR_GREATER ? 10 : 0)

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

@property (nonatomic, assign) BOOL venmoTouchEnabled;
@property (nonatomic, assign) BOOL hasPaymentMethods;

@property (nonatomic, strong) VTClient *client;
@property (nonatomic, strong) BTPaymentActivityOverlayView *paymentActivityOverlayView;
@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, strong) UIView *cellBackgroundView; // for iOS 5/6 visuals
@property (nonatomic, strong) UIView *disabledButtonGradientView;
@property (nonatomic, strong) UIView *normalButtonGradientView;
@property (nonatomic, strong) UIView *pressedButtonGradientView;

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
    self.venmoTouchEnabled = hasVenmoTouchEnabled;
    self.requestsZipInManualCardEntry = YES;

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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (!self.cornerRadius) self.cornerRadius = BT_DEFAULT_CORNER_RADIUS;
    if (!self.viewBackgroundColor) self.viewBackgroundColor = BT_DEFAULT_BACKGROUND_COLOR;
    [self setViewBackgroundColor:self.viewBackgroundColor]; // Changes the display.

    Class class = NSClassFromString(@"VTClient");
    if (class) {
        self.client = [class sharedVTClient];

        if (self.venmoTouchEnabled) {
            if (!self.client) {
                NSLog(@"Venmo Touch is enabled but VTClient has not yet been initialized. Please refer to VTClient.h to initialize it before displaying this BTPaymentViewController, or disable Venmo Touch when creating this BTPaymentViewController.");
            } else {
                self.client.delegate = self;

                if (self.client.paymentMethodOptionStatus == VTPaymentMethodOptionStatusYes) {
                    self.hasPaymentMethods = YES;
                }

                // Register for keyboard notifications to autoscroll on BTPaymentFormView focus.
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(keyboardDidShow:)
                                                             name:UIKeyboardDidShowNotification
                                                           object:self.view.window];
            }
        }
    }

    // Create the payment form
    self.paymentFormView = [BTPaymentFormView paymentFormView];
    self.paymentFormView.delegate = self;
    self.paymentFormView.requestsZip = self.requestsZipInManualCardEntry;
    self.paymentFormView.backgroundColor = [UIColor clearColor];
    self.paymentFormView.UKSupportEnabled = self.UKSupportEnabled;

    // Create the checkbox view, if requested.
    if ([self showsVTCheckbox]) {
        // Set up the VTCheckboxView view
        self.checkboxView = [self.client checkboxView];
        [self.checkboxView setBackgroundColor:[UIColor clearColor]];
        [self.checkboxView setTextColor:[UIColor grayColor]];
    }

    [self setupSubmitButton];
}

- (void)viewDidAppear:(BOOL)animated {
    // If we know the user will have no option of seeing a VTCardView, then give firstResponder
    // to the BTPaymentFormView.
    if ((self.venmoTouchEnabled && self.client &&
        self.client.paymentMethodOptionStatus == VTPaymentMethodOptionStatusNo)
        || !self.venmoTouchEnabled
        || !self.client) {
        [self.paymentFormView.cardNumberTextField becomeFirstResponder];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardDidShow:(NSNotification *)notification {
    // If Use Card button is showing, auto-scroll to bottom cell.
    if (self.tableView.window == [UIApplication sharedApplication].keyWindow) {
        // Check for active window because Venmo Touch may be showing an additional window via its internal HUDs.
        if ([self numberOfSectionsInTableView:self.tableView] == 2) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:1]-1) inSection:1];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

#pragma mark - Submit button

- (void)setupSubmitButton {
    self.submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.submitButton.frame = CGRectMake(0, 0, 0, SUBMIT_BUTTON_HEIGHT);
    self.submitButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.submitButton.clipsToBounds = YES;
    self.submitButton.layer.cornerRadius = self.cornerRadius;
    self.submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.submitButton.accessibilityLabel = @"Submit New Card";
    self.submitButton.backgroundColor = [UIColor whiteColor];
    [self.submitButton setTitle:@"Submit New Card" forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.submitButton addTarget:self action:@selector(submitCardInfo:) forControlEvents:UIControlEventTouchUpInside];

    if (!BT_IS_IOS7_OR_GREATER) {
        [self.submitButton addSubview:self.normalButtonGradientView];
        [self.submitButton bringSubviewToFront:self.submitButton.titleLabel];
        self.submitButton.layer.cornerRadius = self.cornerRadius;
        self.submitButton.layer.borderWidth  = 1;
        self.submitButton.layer.borderColor  = [SUBMIT_BUTTON_BORDER_COLOR CGColor];
        [self.submitButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];

        [self.submitButton addTarget:self action:@selector(submitButtonTouchUpInside)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.submitButton addTarget:self action:@selector(submitButtonTouchDown)
                    forControlEvents:UIControlEventTouchDown];
        [self.submitButton addTarget:self action:@selector(submitButtonTouchDragExit)
                    forControlEvents:UIControlEventTouchDragExit];
        [self.submitButton addTarget:self action:@selector(submitButtonTouchDragEnter)
                    forControlEvents:UIControlEventTouchDragEnter];

        UIView *topShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 1, self.submitButton.frame.size.width, 1)];
        topShadow.backgroundColor = [UIColor colorWithWhite:1 alpha:.1];
        topShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.submitButton addSubview:topShadow];
    }

    self.submitButton.enabled = NO;
}

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
    [self.submitButton addSubview:to];
    [self.submitButton bringSubviewToFront:self.submitButton.titleLabel];
}

#pragma mark - UIScrollView

// Hide keyboard when the user scrolls
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    UITextField *firstResponder;
    if ([self.paymentFormView.cardNumberTextField isFirstResponder]) firstResponder = self.paymentFormView.cardNumberTextField;
    else if ([self.paymentFormView.monthYearTextField isFirstResponder]) firstResponder = self.paymentFormView.monthYearTextField;
    else if ([self.paymentFormView.cvvTextField isFirstResponder]) firstResponder = self.paymentFormView.cvvTextField;
    else if ([self.paymentFormView.zipTextField isFirstResponder]) firstResponder = self.paymentFormView.zipTextField;
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
}

#pragma mark - BTPaymentViewController public methods

- (void)prepareForDismissal {
    [self.paymentActivityOverlayView dismissAnimated:YES];
}

- (void)showErrorWithTitle:(NSString *)title message:(NSString *)message {
    [self.paymentActivityOverlayView dismissAnimated:NO];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark - BTPaymentViewController private methods

- (BOOL)showsVTCheckbox {
    return (self.venmoTouchEnabled && self.client && self.client.liveStatus != VTLiveStatusNo);
}

- (void)submitCardInfo:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(paymentViewController:didSubmitCardWithInfo:andCardInfoEncrypted:)]) {
        if (!self.paymentActivityOverlayView) {
            self.paymentActivityOverlayView = [BTPaymentActivityOverlayView sharedOverlayView];
        }
        [self.paymentActivityOverlayView show];

        // Get card info dictionary from the payment form.
        NSDictionary *cardInfo = [self.paymentFormView cardEntry];
        NSDictionary *cardInfoEncrypted;
        if (self.venmoTouchEnabled && !self.client) {
            NSLog(@"Venmo Touch is enabled but VTClient has not yet been initialized, so the encrypted card information can not be returned to you. Please refer to VTClient.h to initialize it before displaying this BTPaymentViewController, or disable Venmo Touch when creating this BTPaymentViewController.");
        } else if ([self.client braintreeClientSideEncryptionKey]) {
            // If VTClient has a client side encryption key, return encrypted card info.
            cardInfoEncrypted = [self.client encryptedCardDataAndVenmoSDKSessionWithCardDictionary:cardInfo];
        }

        [self.delegate paymentViewController:self didSubmitCardWithInfo:cardInfo andCardInfoEncrypted:cardInfoEncrypted];
    }
}

- (void)paymentMethodFound {
    if (self.hasPaymentMethods) {
        // This case may happen when the user closes the app when viewing the payment form.
        // Open re-opening, [client refresh] will trigger (if no modal is visible) and the
        // cardView would not need animate in again if it already exists.
        self.cardView = nil;
        [self.tableView reloadData];
    } else {
        self.hasPaymentMethods = YES;

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
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasPaymentMethods && indexPath.section == 0) {
        // VTCardView
        return 74 + 6; //+6 to get nice-sized padding between VTCardView (height of 74) and "Submit New Card" button
    } else if (indexPath.row == 0) {
        // BTPaymentFormView
        return 40;
    } else if (indexPath.row == 1) {
        // VTCheckbox (if available) and Submit button
        CGFloat height = ([self showsVTCheckbox] ? self.checkboxView.frame.size.height : SUBMIT_BUTTON_TOP_PADDING)
                          + self.submitButton.frame.size.height;
        return height;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0 ? 40 : 30);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.hasPaymentMethods ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.hasPaymentMethods && section == 0) {
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
    if (section == 0 && self.hasPaymentMethods) {
        // Section for the Use Card button.
        return self.cardViewHeaderView;
    } else {
        // Section that displays the payment form view. Must change the section title accordingly.
        [self.paymentFormHeaderView setIsTopSectionHeader:!self.hasPaymentMethods];
        [self.paymentFormHeaderView setTitleText:(self.hasPaymentMethods ? @"Or, Add a New Card" : @"Add a New Card")];
        return self.paymentFormHeaderView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *UseCardCellIdentifier               = @"UseCardCell";
    static NSString *PaymentFormViewCellIdentifier       = @"PaymentFormViewCell";
    static NSString *PaymentFormViewFooterCellIdentifier = @"PaymentFormViewFooterCell";

    NSString *currentCellIdentifier;
    if (self.hasPaymentMethods && indexPath.section == 0) {
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
    }
    
    if ([currentCellIdentifier isEqualToString:UseCardCellIdentifier]) {
        [self setUpCardViewForCell:cell];
    } else if ([currentCellIdentifier isEqualToString:PaymentFormViewCellIdentifier]) {
        [self setUpPaymentFormViewForCell:cell];
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundView = nil;

    if (self.hasPaymentMethods && indexPath.section == 0) {
        // Venmo Touch row || checkbox + submit button row
        cell.backgroundColor = [UIColor clearColor];
    }
    else if (indexPath.row == 0) {
        if (!BT_IS_IOS7_OR_GREATER && cell.backgroundView.tag != CELL_BACKGROUND_VIEW_TAG) {
            // Customize the cell background view if < iOS 7
            self.cellBackgroundView.frame = cell.frame;
            cell.backgroundView = self.cellBackgroundView;

            [self adjustCellBackgroundViewShadowWidth];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    else {
        CGFloat contentViewWidth = cell.contentView.frame.size.width;

        [self.checkboxView setWidth:contentViewWidth - 20];
        [self.checkboxView setOrigin:CGPointMake(CELL_SIDE_PADDING, 0)];
        [cell.contentView addSubview:self.checkboxView];
        cell.backgroundColor = [UIColor clearColor];

        CGRect submitButtonFrame = CGRectZero;
        submitButtonFrame.origin.x = CELL_SIDE_PADDING;
        submitButtonFrame.origin.y = ([self showsVTCheckbox] ? self.checkboxView.frame.size.height : SUBMIT_BUTTON_TOP_PADDING);
        submitButtonFrame.size.width = contentViewWidth - CELL_SIDE_PADDING*2;
        submitButtonFrame.size.height = SUBMIT_BUTTON_HEIGHT;

        self.submitButton.frame = submitButtonFrame;
        [cell.contentView addSubview:self.submitButton];
    }
}

- (void)adjustCellBackgroundViewShadowWidth {
    // Set the background cell's top shadow width.
    UIView *topShadowView = [self.cellBackgroundView viewWithTag:CELL_BACKGROUND_VIEW_SHADOW_TAG];
    CGFloat topShadowBuffer = ceilf(self.cornerRadius/2.0f + (self.cornerRadius > 10 ? 1 : 0));
    CGRect topShadowFrame = CGRectMake(topShadowBuffer, 1, self.cellBackgroundView.frame.size.width - topShadowBuffer*2, 1);
    topShadowView.frame = topShadowFrame;
}

- (void)setUpCardViewForCell:(UITableViewCell *)cell {
    if (!self.cardView) {
        self.cardView = [self.client cardView];
        self.cardView.tag = VTCARDVIEW_TAG;

        // Set styling defaults if they were set before cardView was initialized
        if (self.cornerRadius)              self.cardView.cornerRadius     = self.cornerRadius;
        if (self.vtCardViewBackgroundColor) self.vtCardViewBackgroundColor = self.vtCardViewBackgroundColor;
        if (self.vtCardViewTitleFont)       self.vtCardViewTitleFont       = self.vtCardViewTitleFont;
        if (self.vtCardViewInfoButtonFont)  self.vtCardViewInfoButtonFont  = self.vtCardViewInfoButtonFont;
    }
    
    if (self.cardView && cell && ![cell.contentView viewWithTag:VTCARDVIEW_TAG]) {
        [self.cardView setOrigin:CGPointMake(CELL_SIDE_PADDING, 0)];
        [self.cardView setBackgroundColor:[UIColor clearColor]];
        [self.cardView setWidth:cell.contentView.frame.size.width - CELL_SIDE_PADDING*2];
        [cell.contentView addSubview:self.cardView];
    }
}

- (void)setUpPaymentFormViewForCell:(UITableViewCell *)cell {
    [self.paymentFormView removeFromSuperview];
    if (BT_IS_IOS7_OR_GREATER) {
        [self.paymentFormView setOrigin:CGPointMake(0, 1)]; // Shift 1 pixel down to vertically center.
    }
    [cell.contentView addSubview:self.paymentFormView];
}

#pragma mark - BTPaymentFormViewDelegate

- (void)paymentFormView:(BTPaymentFormView *)paymentFormView didModifyCardInformationWithValidity:(BOOL)isValid {
    self.submitButton.enabled = isValid;
    self.submitButton.layer.borderColor = [SUBMIT_BUTTON_BORDER_COLOR CGColor];
}

#pragma mark - VTClientDelegate

- (void)client:(VTClient *)client didReceivePaymentMethodOptionStatus:(VTPaymentMethodOptionStatus)paymentMethodOptionStatus {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"loading finished: %d", (int)paymentMethodOptionStatus);
    if (paymentMethodOptionStatus == VTPaymentMethodOptionStatusYes) {
        // Force tableview to reloadData, which renders VTCardView
        NSLog(@"payment method on file");
        [self paymentMethodFound];
    } else if (self.hasPaymentMethods && paymentMethodOptionStatus != VTPaymentMethodOptionStatusYes) {
        self.hasPaymentMethods = NO;
        [self.tableView reloadData];
    }
}

- (void)client:(VTClient *)client didFinishLoadingLiveStatus:(VTLiveStatus)liveStatus {
    NSLog(@"didFinishLoadingLiveStatus: %d", (int)liveStatus);
}

- (void)client:(VTClient *)client approvedPaymentMethodWithCode:(NSString *)paymentMethodCode {
    // Return it to the delegate
    if ([self.delegate respondsToSelector:
         @selector(paymentViewController:didAuthorizeCardWithPaymentMethodCode:)]) {
        if (!self.paymentActivityOverlayView) {
            self.paymentActivityOverlayView = [BTPaymentActivityOverlayView sharedOverlayView];
            [self.paymentActivityOverlayView show];
        }

        [self.delegate paymentViewController:self didAuthorizeCardWithPaymentMethodCode:paymentMethodCode];
    }
}

- (void)clientWillReceivePaymentMethodOptionStatus:(VTClient *)client {
    [self hideVTCardViewSection];
}

- (void)clientDidLogout:(VTClient *)client {
    [self hideVTCardViewSection];
    [self.tableView reloadData]; // Updates section header names.
}

#pragma mark - UI Customization

- (void)setRequestsZipInManualCardEntry:(BOOL)requestsZipInManualCardEntry {
    _requestsZipInManualCardEntry = requestsZipInManualCardEntry;
    self.paymentFormView.requestsZip = requestsZipInManualCardEntry;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (!(0 <= cornerRadius && cornerRadius <= 15)) {
        return;
    } else if (cornerRadius == 0) {
        // This is a hack.
        cornerRadius = 1;
    }

    _cornerRadius = cornerRadius;
    self.cardView.cornerRadius = cornerRadius;
    self.submitButton.layer.cornerRadius = cornerRadius;
}

- (void)setViewBackgroundColor:(UIColor *)color {
    _viewBackgroundColor = color;
    self.tableView.backgroundColor = color;
    self.paymentFormHeaderView.backgroundColor = color;
    self.cardViewHeaderView.backgroundColor = color;
}

- (void)setVtCardViewBackgroundColor:(UIColor *)vtCardViewBackgroundColor {
    _vtCardViewBackgroundColor = vtCardViewBackgroundColor;
    self.cardView.useCardButtonBackgroundColor = vtCardViewBackgroundColor;
}

- (void)setVtCardViewTitleFont:(UIFont *)vtCardViewTitleFont {
    _vtCardViewTitleFont = vtCardViewTitleFont;
    self.cardView.useCardButtonTitleFont = vtCardViewTitleFont;
}

- (void)setVtCardViewInfoButtonFont:(UIFont *)vtCardViewInfoButtonFont {
    _vtCardViewInfoButtonFont = vtCardViewInfoButtonFont;
    self.cardView.infoButtonFont = vtCardViewInfoButtonFont;
}

- (void)setUKSupportEnabled:(BOOL)UKSupportEnabled {
    _UKSupportEnabled = UKSupportEnabled;
    self.paymentFormView.UKSupportEnabled = UKSupportEnabled;
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
        [_cardViewHeaderView setTitleText:@"Use a Saved Card"];
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

- (UIView *)cellBackgroundView {
    if (!_cellBackgroundView) {
        _cellBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
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
    }
    return _cellBackgroundView;
}

@end
