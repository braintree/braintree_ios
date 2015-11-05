#import "BTPaymentButton.h"

@interface BTPaymentButton () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *paymentButtonsCollectionView;

@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;

/// Collection of payment option strings, e.g. "PayPal", "Coinbase"
- (NSOrderedSet *)filteredEnabledPaymentOptions;
@end
