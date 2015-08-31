#import "BTPaymentButton.h"

#import "BTClient.h"
#import "BTLogger_Internal.h"
#import "BTUIVenmoButton.h"
#import "BTUIPayPalButton.h"
#import "BTUICoinbaseButton.h"

#import "BTPaymentProvider.h"
#import "BTUIHorizontalButtonStackCollectionViewFlowLayout.h"
#import "BTUIPaymentButtonCollectionViewCell.h"

NSString *BTPaymentButtonPaymentButtonCellIdentifier = @"BTPaymentButtonPaymentButtonCellIdentifier";

@interface BTPaymentButton () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BTPaymentMethodCreationDelegate>
@property (nonatomic, strong) UICollectionView *paymentButtonsCollectionView;
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;

@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, strong) NSOrderedSet *filteredEnabledPaymentProviderTypes;

@end

@implementation BTPaymentButton

- (id)init {
    self = [super init];
    return self;
}

- (instancetype)initWithPaymentProviderTypes:(NSOrderedSet *)enabledPaymentProviderTypes {
    self = [self init];
    if (self) {
        [self setupViews];
        if (enabledPaymentProviderTypes) {
            self.enabledPaymentProviderTypes = enabledPaymentProviderTypes;
        }
    }
    return self;
}

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
    self.clipsToBounds = YES;
    self.enabledPaymentProviderTypes = [NSOrderedSet orderedSetWithObjects:
                                        @(BTPaymentProviderTypePayPal),
                                        @(BTPaymentProviderTypeVenmo),
                                        @(BTPaymentProviderTypeCoinbase),
                                        nil];

    BTUIHorizontalButtonStackCollectionViewFlowLayout *layout = [[BTUIHorizontalButtonStackCollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.0f;

    self.paymentButtonsCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                           collectionViewLayout:layout];
    self.paymentButtonsCollectionView.accessibilityIdentifier = @"Payment Options";
    self.paymentButtonsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.paymentButtonsCollectionView.allowsSelection = YES;
    self.paymentButtonsCollectionView.delaysContentTouches = NO;
    self.paymentButtonsCollectionView.delegate = self;
    self.paymentButtonsCollectionView.dataSource = self;
    self.paymentButtonsCollectionView.backgroundColor = [UIColor grayColor];
    [self.paymentButtonsCollectionView registerClass:[BTUIPaymentButtonCollectionViewCell class] forCellWithReuseIdentifier:BTPaymentButtonPaymentButtonCellIdentifier];

    self.topBorder = [[UIView alloc] init];
    self.topBorder.backgroundColor = [self.theme borderColor];
    self.topBorder.translatesAutoresizingMaskIntoConstraints = NO;

    self.bottomBorder = [[UIView alloc] init];
    self.bottomBorder.backgroundColor = [self.theme borderColor];
    self.bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.paymentButtonsCollectionView];
    [self addSubview:self.topBorder];
    [self addSubview:self.bottomBorder];

    self.paymentProvider = [[BTPaymentProvider alloc] initWithClient:self.client];
    self.paymentProvider.delegate = self;
}

- (CGSize)intrinsicContentSize {
    CGFloat height = self.filteredEnabledPaymentProviderTypes.count > 0 ? 44 : 0;

    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.paymentButtonsCollectionView.collectionViewLayout invalidateLayout];
}

- (void)updateConstraints {
    NSDictionary *views = @{ @"paymentButtonsCollectionView": self.paymentButtonsCollectionView,
                             @"topBorder": self.topBorder,
                             @"bottomBorder": self.bottomBorder };
    NSDictionary *metrics = @{ @"borderWidth": @(self.theme.borderWidth) };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[paymentButtonsCollectionView]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[paymentButtonsCollectionView]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topBorder]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topBorder(==borderWidth)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomBorder]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBorder(==borderWidth)]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    [super updateConstraints];
}

#pragma mark PaymentButton State

- (void)setClient:(BTClient *)client {
    _client = client;
    self.paymentProvider.client = client;
}

- (void)setEnabledPaymentProviderTypes:(NSOrderedSet *)enabledPaymentProviderTypes {
    _enabledPaymentProviderTypes = enabledPaymentProviderTypes;

    [self invalidateIntrinsicContentSize];
    [self.paymentButtonsCollectionView reloadData];
}

- (NSOrderedSet *)filteredEnabledPaymentProviderTypes {
    if (!_filteredEnabledPaymentProviderTypes) {
        NSMutableOrderedSet *mutableProviderTypes = [self.enabledPaymentProviderTypes mutableCopy];

        if (![self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeVenmo]) {
            [mutableProviderTypes removeObject:@(BTPaymentProviderTypeVenmo)];
        }
        if (![self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypePayPal]) {
            [mutableProviderTypes removeObject:@(BTPaymentProviderTypePayPal)];
        }
        if (![self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase]) {
            [mutableProviderTypes removeObject:@(BTPaymentProviderTypeCoinbase)];
        }
        _filteredEnabledPaymentProviderTypes = [mutableProviderTypes copy];
    }
 
    return _filteredEnabledPaymentProviderTypes;
}

- (BOOL)hasAvailablePaymentMethod {
    return [self filteredEnabledPaymentProviderTypes].count > 0 ? YES : NO;
}

- (BTPaymentProviderType)paymentProviderForIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    NSNumber *paymentProviderTypeNumber = self.filteredEnabledPaymentProviderTypes[index];
    return (BTPaymentProviderType)[paymentProviderTypeNumber integerValue];
}

#pragma mark UICollectionViewDataSource methods

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView numberOfItemsInSection:(__unused NSInteger)section {
    NSParameterAssert(section == 0);
    return [self.filteredEnabledPaymentProviderTypes count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath.section == 0);

    BTUIPaymentButtonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BTPaymentButtonPaymentButtonCellIdentifier
                                                                                        forIndexPath:indexPath];
    BTPaymentProviderType paymentMethod = [self paymentProviderForIndexPath:indexPath];

    UIControl *paymentButton;
    switch (paymentMethod) {
        case BTPaymentProviderTypePayPal:
            paymentButton = [[BTUIPayPalButton alloc] initWithFrame:cell.bounds];
            break;
        case BTPaymentProviderTypeVenmo:
            paymentButton = [[BTUIVenmoButton alloc] initWithFrame:cell.bounds];
            break;
        case BTPaymentProviderTypeCoinbase:
            paymentButton = [[BTUICoinbaseButton alloc] initWithFrame:cell.bounds];
            break;
        default:
            [[BTLogger sharedLogger] warning:@"BTPaymentButton encountered an unexpected BTPaymentProviderType value: %@", @(paymentMethod)];
            return cell;
    }
    paymentButton.translatesAutoresizingMaskIntoConstraints = NO;

    cell.paymentButton = paymentButton;

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

- (void)collectionView:(__unused UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(self.client, @"BTPaymentButton tapped without a BTClient instance. Please set a client on this payment button: myPaymentButton.client = (BTClient *)myClient;");

    BTPaymentProviderType paymentMethod = [self paymentProviderForIndexPath:indexPath];

    switch (paymentMethod) {
        case BTPaymentProviderTypePayPal:
            [self.paymentProvider createPaymentMethod:BTPaymentProviderTypePayPal];
            break;
        case BTPaymentProviderTypeVenmo:
            [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeVenmo];
            break;
        case BTPaymentProviderTypeCoinbase:
            [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeCoinbase];
            break;
        default:
            NSLog(@"BTPaymentButton collection view received didSelectItemAtIndexPath for unknown indexPath. This should never happen.");
            break;
    }
}

#pragma mark Delegate informers

- (void)informDelegateWillPerformAppSwitch {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillPerformAppSwitch:)]) {
        [self.delegate paymentMethodCreatorWillPerformAppSwitch:self];
    }
}

- (void)informDelegateWillProcess {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillProcess:)]) {
        [self.delegate paymentMethodCreatorWillProcess:self];
    }
}

- (void)informDelegateRequestsPresentationOfViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsPresentationOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsPresentationOfViewController:viewController];
    }
}

- (void)informDelegateRequestsDismissalOfViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsDismissalOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsDismissalOfViewController:viewController];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didCreatePaymentMethod:)]) {
        [self.delegate paymentMethodCreator:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didFailWithError:)]) {
        [self.delegate paymentMethodCreator:self didFailWithError:error];
    }
}

- (void)informDelegateDidCancel {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorDidCancel:)]) {
        [self.delegate paymentMethodCreatorDidCancel:self];
    }
}

#pragma mark - BTPaymentProvider Delegate

- (void)paymentMethodCreator:(__unused id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
    [self informDelegateRequestsPresentationOfViewController:viewController];
}

- (void)paymentMethodCreator:(__unused id)sender requestsDismissalOfViewController:(UIViewController *)viewController {
    [self informDelegateRequestsDismissalOfViewController:viewController];
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(__unused id)sender {
    [self informDelegateWillPerformAppSwitch];
}

- (void)paymentMethodCreatorWillProcess:(__unused id)sender {
    [self informDelegateWillProcess];
}

- (void)paymentMethodCreatorDidCancel:(__unused id)sender {
    [self informDelegateDidCancel];
}

- (void)paymentMethodCreator:(__unused id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self informDelegateDidCreatePaymentMethod:paymentMethod];
}

- (void)paymentMethodCreator:(__unused id)sender didFailWithError:(NSError *)error {
    [self informDelegateDidFailWithError:error];
}

@end
