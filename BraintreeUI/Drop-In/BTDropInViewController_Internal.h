#import "BTDropInViewController.h"

#import "BTDropInContentView.h"
#import "BTDropInErrorAlert.h"
#import "BTDropInErrorState.h"
#import "BTDropInLocalizedString.h"
#import "BTDropInSelectPaymentMethodViewController.h"
#import "BTDropInUtil.h"
#import "BTPaymentMethodNonceParser.h"
#import "BTTokenizationService.h"
#import "BTUICardFormView.h"
#import "BTUIScrollView.h"

@interface BTDropInViewController () <BTUIScrollViewScrollRectToVisibleDelegate, BTUICardFormViewDelegate, BTDropInViewControllerDelegate, BTDropInSelectPaymentMethodViewControllerDelegate, BTViewControllerPresentingDelegate>

@property (nonatomic, strong) BTDropInContentView *dropInContentView;
@property (nonatomic, strong) BTDropInViewController *addPaymentMethodDropInViewController;
@property (nonatomic, strong) BTUIScrollView *scrollView;
@property (nonatomic, assign) NSInteger selectedPaymentMethodNonceIndex;
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
@property (nonatomic, assign) BOOL cardEntryDidFocus;

@property (nonatomic, assign) BOOL originalCoinbaseStoreInVault;

@end
