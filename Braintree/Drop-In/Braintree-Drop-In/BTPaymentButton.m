#import "BTPaymentButton.h"

#import "BTClient.h"

#import "BTUIVenmoButton.h"
#import "BTUIPayPalButton.h"

#import "BTVenmoAppSwitchHandler.h"
#import "BTPayPalAdapter.h"

#import <FLEX/FLEXManager.h>

@interface BTPaymentButton () <BTAppSwitchingDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
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
    self.paymentButtonsCollectionView.allowsSelection = NO;
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
        paymentButton = [[BTUIPayPalButton alloc] initWithFrame:cell.bounds];
    } else {
        paymentButton = [[BTUIVenmoButton alloc] initWithFrame:cell.bounds];
        [paymentButton addTarget:self action:@selector(tappedVenmo:) forControlEvents:UIControlEventTouchUpInside];
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

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(__unused UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(__unused NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width / 2;
    return CGSizeMake(width, 44);
}

#pragma mark Payment Button Handlers

- (void)tappedVenmo:(id)sender {
    NSLog(@"Tapped Venmo: %@", sender);
    NSAssert(self.client, @"BTPaymentButton tapped without a BTClient instance. Please set a client on this payment button: myPaymentButton.client = (BTClient *)myClient;");
    BOOL performedAppSwitch = [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self];
    // TODO: Do something if app switch fails
    NSLog(@"[BTPaymentButton] Performed app switch: %@", performedAppSwitch ? @"YES": @"NO");
}

#pragma mark App Switching Delegate

- (void)appSwitcherWillSwitch:(__unused id<BTAppSwitching>)switcher {
    [self.delegate paymentMethodAuthorizerWillRequestUserChallengeWithAppSwitch:self];
}

- (void)appSwitcherWillCreatePaymentMethod:(__unused id<BTAppSwitching>)switcher {
    [self.delegate paymentMethodAuthorizerDidCompleteUserChallenge:self];
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

@end
