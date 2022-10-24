#import "BraintreeDemoAmexViewController.h"
@import BraintreeAmericanExpress;
@import BraintreeCard;

@interface BraintreeDemoAmexViewController ()

@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, strong) BTCardClient *cardClient;
@property (nonatomic, strong) BTAmericanExpressClient *amexClient;

@end

@implementation BraintreeDemoAmexViewController

- (instancetype)initWithAuthorization:(NSString *)authorization {
    self = [super initWithAuthorization:authorization];
    if (self) {
        _apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
        _amexClient = [[BTAmericanExpressClient alloc] initWithAPIClient:_apiClient];
        _cardClient = [[BTCardClient alloc] initWithAPIClient:_apiClient];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Amex", nil);

    UIButton *validCardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [validCardButton setTitle:NSLocalizedString(@"Valid card", nil) forState:UIControlStateNormal];
    [validCardButton addTarget:self action:@selector(tappedValidCard) forControlEvents:UIControlEventTouchUpInside];

    UIButton *insufficientPointsCardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [insufficientPointsCardButton setTitle:NSLocalizedString(@"Insufficient points card", nil) forState:UIControlStateNormal];
    [insufficientPointsCardButton addTarget:self action:@selector(tappedInsufficientPointsCard) forControlEvents:UIControlEventTouchUpInside];

    UIButton *ineligibleCardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [ineligibleCardButton setTitle:NSLocalizedString(@"Ineligible card", nil) forState:UIControlStateNormal];
    [ineligibleCardButton addTarget:self action:@selector(tappedIneligibleCard) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[validCardButton, insufficientPointsCardButton, ineligibleCardButton]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.spacing = 20;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

- (void)tappedValidCard {
    [self getRewardsForCardNumber:@"371260714673002"];
}

- (void)tappedInsufficientPointsCard {
    [self getRewardsForCardNumber:@"371544868764018"];
}

- (void)tappedIneligibleCard {
    [self getRewardsForCardNumber:@"378267515471109"];
}

- (void)getRewardsForCardNumber:(NSString *)cardNumber {
    BTCard *card = [BTCard new];
    card.number = cardNumber;
    card.expirationMonth = @"12";
    card.expirationYear = @"2025";
    card.cvv = @"1234";
    
    self.progressBlock(@"Tokenizing Card");

    [self.cardClient tokenizeCard:card completion:^(BTCardNonce *tokenized, NSError *error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
            NSLog(@"Error: %@", error);
            return;
        }

        self.progressBlock(@"Amex - getting rewards balance");
        [self.amexClient getRewardsBalanceForNonce:tokenized.nonce currencyIsoCode:@"USD" completion:^(BTAmericanExpressRewardsBalance *rewardsBalance, NSError *error) {
            if (error) {
                self.progressBlock(error.localizedDescription);
            } else if (rewardsBalance.errorCode) {
                self.progressBlock([NSString stringWithFormat:@"%@: %@", rewardsBalance.errorCode, rewardsBalance.errorMessage]);
            } else {
                self.progressBlock([NSString stringWithFormat:@"%@ %@, %@ %@", rewardsBalance.rewardsAmount, rewardsBalance.rewardsUnit, rewardsBalance.currencyAmount, rewardsBalance.currencyIsoCode]);
            }
        }];
    }];
}

@end
