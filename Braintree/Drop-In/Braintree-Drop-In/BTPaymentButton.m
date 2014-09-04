#import "BTPaymentButton.h"

#import "BTClient.h"

#import "BTUIVenmoButton.h"
#import "BTUIPayPalButton.h"

#import "BTPaymentAuthorizer.h"
#import "BTHorizontalButtonStackCollectionViewFlowLayout.h"
#import "BTPaymentButtonCollectionViewCell.h"

NSString *BTPaymentButtonPaymentButtonCellIdentifier = @"BTPaymentButtonPaymentButtonCellIdentifier";
NSInteger BTPaymentButtonPayPalCellIndex = 0;
NSInteger BTPaymentButtonVenmoCellIndex = 1;

@interface BTPaymentButton () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BTPaymentAuthorizerDelegate>
@property (nonatomic, strong) UICollectionView *paymentButtonsCollectionView;
@property (nonatomic, strong) BTPaymentAuthorizer *paymentAuthorizer;

@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@end

@implementation BTPaymentButton

- (id)init {
    self = [super init];
    if (self) {
        [self setupViews];
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
    self.enabledPaymentMethods = [NSOrderedSet orderedSetWithObjects:@(BTPaymentAuthorizationTypePayPal), @(BTPaymentAuthorizationTypeVenmo), nil];

    BTHorizontalButtonStackCollectionViewFlowLayout *layout = [[BTHorizontalButtonStackCollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.0f;

    self.paymentButtonsCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                           collectionViewLayout:layout];
    self.paymentButtonsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.paymentButtonsCollectionView.allowsSelection = YES;
    self.paymentButtonsCollectionView.delaysContentTouches = NO;
    self.paymentButtonsCollectionView.delegate = self;
    self.paymentButtonsCollectionView.dataSource = self;
    self.paymentButtonsCollectionView.backgroundColor = [UIColor grayColor];
    [self.paymentButtonsCollectionView registerClass:[BTPaymentButtonCollectionViewCell class] forCellWithReuseIdentifier:BTPaymentButtonPaymentButtonCellIdentifier];

    self.topBorder = [[UIView alloc] init];
    self.topBorder.backgroundColor = [self.theme borderColor];
    self.topBorder.translatesAutoresizingMaskIntoConstraints = NO;

    self.bottomBorder = [[UIView alloc] init];
    self.bottomBorder.backgroundColor = [self.theme borderColor];
    self.bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.paymentButtonsCollectionView];
    [self addSubview:self.topBorder];
    [self addSubview:self.bottomBorder];

    self.paymentAuthorizer = [[BTPaymentAuthorizer alloc] initWithClient:self.client];
    self.paymentAuthorizer.delegate = self;
}

- (CGSize)intrinsicContentSize {
    CGFloat height = self.enabledPaymentMethods.count > 0 ? 44 : 0;

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
    self.paymentAuthorizer.client = client;
}

- (void)setEnabledPaymentMethods:(NSOrderedSet *)enabledPaymentMethods {
    _enabledPaymentMethods = enabledPaymentMethods;

    [self invalidateIntrinsicContentSize];
    [self.paymentButtonsCollectionView reloadData];
}

- (NSOrderedSet *)filteredEnabledPaymentMethods {
    NSMutableOrderedSet *filteredEnabledPaymentMethods = [self.enabledPaymentMethods mutableCopy];
    if (![self.paymentAuthorizer supportsAuthorizationType:BTPaymentAuthorizationTypeVenmo]) {
        [filteredEnabledPaymentMethods removeObject:@(BTPaymentAuthorizationTypeVenmo)];
    }
    if (![self.paymentAuthorizer supportsAuthorizationType:BTPaymentAuthorizationTypePayPal]) {
        [filteredEnabledPaymentMethods removeObject:@(BTPaymentAuthorizationTypePayPal)];
    }
    return filteredEnabledPaymentMethods;
}

#pragma mark UICollectionViewDataSource methods

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSParameterAssert(section == 0);
    return [self.filteredEnabledPaymentMethods count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath.section == 0);

    BTPaymentButtonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BTPaymentButtonPaymentButtonCellIdentifier
                                                                                        forIndexPath:indexPath];

    NSInteger index = indexPath.row;
    id v = self.filteredEnabledPaymentMethods[index];
    BTPaymentAuthorizationType paymentMethod = [v integerValue];

    UIControl *paymentButton;
    switch (paymentMethod) {
        case BTPaymentAuthorizationTypePayPal:
            paymentButton = [[BTUIPayPalButton alloc] initWithFrame:cell.bounds];
            break;
        case BTPaymentAuthorizationTypeVenmo:
            paymentButton = [[BTUIVenmoButton alloc] initWithFrame:cell.bounds];
            break;
        default:
            break;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BTPaymentButtonCollectionViewCell *cell = (BTPaymentButtonCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    NSAssert(self.client, @"BTPaymentButton tapped without a BTClient instance. Please set a client on this payment button: myPaymentButton.client = (BTClient *)myClient;");
    if (indexPath.row == BTPaymentButtonPayPalCellIndex) {
        [self.paymentAuthorizer authorize:BTPaymentAuthorizationTypePayPal];
    } else if (indexPath.row == BTPaymentButtonVenmoCellIndex) {
        [self.paymentAuthorizer authorize:BTPaymentAuthorizationTypeVenmo];
    } else {
        NSLog(@"Should never happen");
    }

    NSLog(@"selected cell: %@", cell);
}

#pragma mark - BTPaymentAuthorizer Delegate

- (void)paymentAuthorizer:(__unused id)sender requestsAuthorizationWithViewController:(UIViewController *)viewController {
    [self informDelegateRequestsAuthorizationWithViewController:viewController];
}

- (void)paymentAuthorizer:(__unused id)sender requestsDismissalOfAuthorizationViewController:(UIViewController *)viewController {
    [self informDelegateRequestsDismissalOfAuthorizationViewController:viewController];
}

- (void)paymentAuthorizerWillRequestAuthorizationWithAppSwitch:(__unused id)sender {
    [self informDelegateWillRequestAuthorizationWithAppSwitch];
}

- (void)paymentAuthorizerWillProcessAuthorizationResponse:(__unused id)sender {
    [self informDelegateWillProcessAuthorizationResponse];
}

- (void)paymentAuthorizerDidCancel:(__unused id)sender {
    [self informDelegateDidCancel];
}

- (void)paymentAuthorizer:(__unused id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self informDelegateDidCreatePaymentMethod:paymentMethod];
}

- (void)paymentAuthorizer:(__unused id)sender didFailWithError:(NSError *)error {
    [self informDelegateDidFailWithError:error];
}


- (void)informDelegateWillRequestAuthorizationWithAppSwitch {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizerWillRequestAuthorizationWithAppSwitch:)]) {
        [self.delegate paymentAuthorizerWillRequestAuthorizationWithAppSwitch:self];
    }
}

- (void)informDelegateWillProcessAuthorizationResponse {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizerWillProcessAuthorizationResponse:)]) {
        [self.delegate paymentAuthorizerWillProcessAuthorizationResponse:self];
    }
}

- (void)informDelegateRequestsAuthorizationWithViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:requestsAuthorizationWithViewController:)]) {
        [self.delegate paymentAuthorizer:self requestsAuthorizationWithViewController:viewController];
    }
}

- (void)informDelegateRequestsDismissalOfAuthorizationViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:requestsDismissalOfAuthorizationViewController:)]) {
        [self.delegate paymentAuthorizer:self requestsDismissalOfAuthorizationViewController:viewController];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:didCreatePaymentMethod:)]) {
        [self.delegate paymentAuthorizer:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:didFailWithError:)]) {
        [self.delegate paymentAuthorizer:self didFailWithError:error];
    }
}

- (void)informDelegateDidCancel {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizerDidCancel:)]) {
        [self.delegate paymentAuthorizerDidCancel:self];
    }
}

@end
