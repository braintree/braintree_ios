#import "BTPaymentButton.h"

#import "BTClient.h"

#import "BTUIVenmoButton.h"
#import "BTUIPayPalButton.h"

#import "BTPaymentMethodAuthorizationDelegate.h"
#import "BTVenmoAppSwitchHandler.h"
#import "BTPayPalAdapter.h"
#import "BTHorizontalButtonStackCollectionViewFlowLayout.h"
#import "BTPaymentButtonCollectionViewCell.h"

NSString *BTPaymentButtonPaymentButtonCellIdentifier = @"BTPaymentButtonPaymentButtonCellIdentifier";

@interface BTPaymentButton () <BTAppSwitchingDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BTPayPalAdapterDelegate>
@property (nonatomic, strong) UICollectionView *paymentButtonsCollectionView;
@property (nonatomic, strong) BTPayPalAdapter *payPalAdapter;
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

    [self addSubview:self.paymentButtonsCollectionView];

    // TODO: Use new interface instead of BTPayPalAdapter
    self.payPalAdapter = [[BTPayPalAdapter alloc] initWithClient:self.client];
    self.payPalAdapter.delegate = self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.paymentButtonsCollectionView.collectionViewLayout invalidateLayout];
}

- (void)setClient:(BTClient *)client {
    _client = client;
    self.payPalAdapter.client = client;
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

- (UICollectionReusableView *)collectionView:(__unused UICollectionView *)collectionView viewForSupplementaryElementOfKind:(__unused NSString *)kind atIndexPath:(__unused NSIndexPath *)indexPath {
    NSLog(@"supp");
    return nil;
}

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSParameterAssert(section == 0);
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BTPaymentButtonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BTPaymentButtonPaymentButtonCellIdentifier
                                                                                        forIndexPath:indexPath];

    UIControl *paymentButton;
    if (indexPath.row == 0) {
        paymentButton = [[BTUIPayPalButton alloc] initWithFrame:cell.bounds];
    } else {
        paymentButton = [[BTUIVenmoButton alloc] initWithFrame:cell.bounds];
        [paymentButton addTarget:self action:@selector(tappedVenmo:) forControlEvents:UIControlEventTouchUpInside];
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

    if (indexPath.row == 0) {
        [self tappedPayPal:cell];
    } else {
        [self tappedVenmo:cell];
    }

    NSLog(@"selected cell: %@", cell);
}

#pragma mark Payment Button Handlers

- (void)tappedVenmo:(id)sender {
    NSLog(@"Tapped Venmo: %@", sender);
    NSAssert(self.client, @"BTPaymentButton tapped without a BTClient instance. Please set a client on this payment button: myPaymentButton.client = (BTClient *)myClient;");
    BOOL performedAppSwitch = [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self];
    // TODO: Do something if app switch fails
    NSLog(@"[BTPaymentButton] Performed app switch: %@", performedAppSwitch ? @"YES": @"NO");
}

- (void)tappedPayPal:(id)sender {
    NSLog(@"Tapped PayPal: %@", sender);

    [self.payPalAdapter initiatePayPalAuth];
}

#pragma mark - App Switching Delegate

- (void)appSwitcherWillSwitch:(__unused id<BTAppSwitching>)switcher {
    [self.delegate paymentMethodAuthorizerWillRequestUserChallengeWithAppSwitch:self];
}

- (void)appSwitcherWillCreatePaymentMethod:(__unused id<BTAppSwitching>)switcher {
    [self.delegate paymentMethodAuthorizerDidCompleteUserChallengeWithAppSwitch:self];
}

- (void)appSwitcher:(__unused id<BTAppSwitching>)switcher didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.delegate paymentMethodAuthorizer:self didCreatePaymentMethod:paymentMethod];
}

- (void)appSwitcher:(__unused id<BTAppSwitching>)switcher didFailWithError:(NSError *)error {
    [self.delegate paymentMethodAuthorizer:self didFailWithError:error];
}

- (void)appSwitcherDidCancel:(__unused id<BTAppSwitching>)switcher {
    NSLog(@"Cancel");
}

#pragma mark - BTPayPalAdapter Delegate

- (void)payPalAdapterWillCreatePayPalPaymentMethod:(BTPayPalAdapter *)payPalAdapter {
    NSLog(@"%@", payPalAdapter);
    [self.delegate paymentMethodAuthorizerDidCompleteUserChallengeWithAppSwitch:self];
}

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    NSLog(@"%@", payPalAdapter);
    [self.delegate paymentMethodAuthorizer:self didCreatePaymentMethod:paymentMethod];
}

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter didFailWithError:(NSError *)error {
    NSLog(@"%@", payPalAdapter);

    [self.delegate paymentMethodAuthorizer:self didFailWithError:error];
}

- (void)payPalAdapterDidCancel:(BTPayPalAdapter *)payPalAdapter {
    NSLog(@"%@", payPalAdapter);

    [self.delegate paymentMethodAuthorizerDidCompleteUserChallengeWithAppSwitch:self];
}

- (void)payPalAdapterWillAppSwitch:(BTPayPalAdapter *)payPalAdapter {
    NSLog(@"%@", payPalAdapter);

    [self.delegate paymentMethodAuthorizerWillRequestUserChallengeWithAppSwitch:self];
}

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter requestsPresentationOfViewController:(UIViewController *)viewController {
    NSLog(@"%@", payPalAdapter);

    [self.delegate paymentMethodAuthorizer:self requestsUserChallengeWithViewController:viewController];

}

- (void)payPalAdapter:(BTPayPalAdapter *)payPalAdapter requestsDismissalOfViewController:(UIViewController *)viewController {
    NSLog(@"%@", payPalAdapter);

    [self.delegate paymentMethodAuthorizer:self requestsDismissalOfUserChallengeViewController:viewController];
}

@end
