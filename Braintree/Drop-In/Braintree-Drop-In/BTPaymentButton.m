#import "BTPaymentButton.h"

#import "BTUIVenmoButton.h"
#import "BTPayPalButton.h"

#import <FLEX/FLEXManager.h>

@interface BTPaymentButton () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *paymentButtonsCollectionView;
@end

@implementation BTPaymentButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [[FLEXManager sharedManager] showExplorer];

    UICollectionViewFlowLayout *defaultLayout = [[UICollectionViewFlowLayout alloc] init];
    defaultLayout.minimumInteritemSpacing = 00.0f;

    self.paymentButtonsCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                           collectionViewLayout:defaultLayout];
    self.paymentButtonsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.paymentButtonsCollectionView.delegate = self;
    self.paymentButtonsCollectionView.dataSource = self;
    self.paymentButtonsCollectionView.backgroundColor = [UIColor grayColor];
    [self.paymentButtonsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PaymentButtonCell"];

    [self addSubview:self.paymentButtonsCollectionView];
}

- (void)updateConstraints {
    NSDictionary *views = @{ @"paymentButtonsCollectionView": self.paymentButtonsCollectionView };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[paymentButtonsCollectionView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[paymentButtonsCollectionView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];

    [super updateConstraints];
}

#pragma mark UICollectionViewDataSource methods

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSParameterAssert(section == 0);
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PaymentButtonCell" forIndexPath:indexPath];

    UIControl *paymentButton;
    if (indexPath.row == 0) {
        paymentButton = [[BTPayPalButton alloc] init];
    } else {
        paymentButton = [[BTUIVenmoButton alloc] initWithFrame:cell.bounds];
    }
    
    paymentButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [cell.contentView addSubview:paymentButton];
    
    NSDictionary *views = @{ @"paymentButton": paymentButton };
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[paymentButton]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[paymentButton]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];

    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(__unused UICollectionView *)collectionView layout:(__unused UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(__unused NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width / 2;
    return CGSizeMake(width, 44);
}

@end
