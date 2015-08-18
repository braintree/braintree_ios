#import <UIKit/UIKit.h>
#import "BTUI.h"

/// The Call To Action control is A button that is intended to be used as the submit button
/// on the bottom of a payment form. As a UIControl subclass, typical target-action event
/// listeners are available.
@interface BTUICTAControl : UIControl

/// The amount, including a currency symbol, to be displayed. May be nil.
@property (nonatomic, copy) NSString *amount;

/// The call to action verb, such as "Subscribe" or "Buy". Must be non-nil.
@property (nonatomic, copy) NSString *callToAction;

- (void)showLoadingState:(BOOL)loadingState;

@property (nonatomic, strong) BTUI *theme;

@end
