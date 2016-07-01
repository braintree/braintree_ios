#import <UIKit/UIKit.h>

@protocol BTKExpiryInputViewDelegate;

/// @class A UIView designed to be used as an `inputView` on a text field.
/// This input view makes it possible to enter a valid expiration date with 2 taps by showing buttons for months and years.
@interface BTKExpiryInputView : UIView <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/// The selected year
@property (nonatomic) NSInteger selectedYear;
/// The selected month
@property (nonatomic) NSInteger selectedMonth;
/// The delegate that should receive expiryInputViewDidChange calls
@property (nonatomic, weak) id<BTKExpiryInputViewDelegate> delegate;

@end

/// @protocol This protocol is required by the delegate to receive the expiryInputViewDidChange calls
@protocol BTKExpiryInputViewDelegate <NSObject>

- (void)expiryInputViewDidChange:(BTKExpiryInputView *)expiryInputView;

@end
