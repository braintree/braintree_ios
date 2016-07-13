#import <UIKit/UIKit.h>

@protocol BTKExpiryInputViewDelegate;

@interface BTKExpiryInputView : UIView <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) NSInteger selectedYear;
@property (nonatomic) NSInteger selectedMonth;
@property (nonatomic, weak) id<BTKExpiryInputViewDelegate> delegate;

@end

@protocol BTKExpiryInputViewDelegate <NSObject>

- (void)expiryInputViewDidChange:(BTKExpiryInputView *)expiryInputView;

@end
