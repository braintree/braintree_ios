#import "BTUIThemedView.h"

#import "Braintree-Payments-UI.h"
#import "Braintree-PayPal.h"

typedef NS_ENUM(NSUInteger, BTDropInContentViewStateType) {
    BTDropInContentViewStateForm = 0,
    BTDropInContentViewStatePaymentMethodsOnFile,
    BTDropInContentViewStateActivity
};

/// A thin view layer that manages Drop In subviews and their layout.
@interface BTDropInContentView : BTUIThemedView

@property (nonatomic, strong) BTUISummaryView *summaryView;
@property (nonatomic, strong) BTUICTAControl *ctaControl;
@property (nonatomic, strong) BTPayPalButton *payPalButton;
@property (nonatomic, strong) UILabel *cardFormSectionHeader;
@property (nonatomic, strong) BTUICardFormView *cardForm;

@property (nonatomic, strong) BTUIPaymentMethodView *selectedPaymentMethodView;
@property (nonatomic, strong) UIButton *changeSelectedPaymentMethodButton;

/// Whether to hide the call to action
@property (nonatomic, assign) BOOL hideCTA;

/// Whether to hide the summary banner view
@property (nonatomic, assign) BOOL hideSummary;

/// The current state
@property (nonatomic, assign) BTDropInContentViewStateType state;

///  Whether the PayPal control is hidden
@property (nonatomic, assign) BOOL hidePayPal;

- (void)setState:(BTDropInContentViewStateType)newState animate:(BOOL)animate;

@end
