#import "BTPaymentSelectionViewController.h"
#import "BTUIPaymentMethodCollectionViewCell.h"
#import "BTDropInController.h"
#import "BTUIKPaymentOptionCardView.h"
#import "BTUIKPaymentOptionType.h"
#import "BTUIKViewUtil.h"
#import "BTDropInPaymentSeletionCell.h"
#if __has_include("BraintreeCard.h")
#import "BTAPIClient_Internal.h"
#import "BraintreeCard.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCard/BraintreeCard.h>
#endif

#define SAVED_PAYMENT_METHODS_COLLECTION_SPACING 6
#define SAVED_PAYMENT_METHODS_COLLECTION_WIDTH 105
#define SAVED_PAYMENT_METHODS_COLLECTION_HEIGHT 165

@interface BTPaymentSelectionViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollViewContentWrapper;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIStackView *paymentOptionsLabelContainerStackView;
@property (nonatomic, strong) UIStackView *vaultedPaymentsLabelContainerStackView;
@property (nonatomic, strong) NSArray *paymentOptionsData;
@property (nonatomic, strong) UITableView *paymentOptionsTableView;
@property (nonatomic, strong) NSLayoutConstraint *collectionViewConstraint;
@property (nonatomic, strong) UILabel *paymentOptionsHeader;
@property (nonatomic, strong) UILabel *vaultedPaymentsHeader;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation BTPaymentSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = @"Select Payment Method";
    
    self.paymentMethodNonces = @[];
    self.paymentOptionsData = @[@(BTUIKPaymentOptionTypePayPal), @(BTUIKPaymentOptionTypeUnknown)];

    self.view.translatesAutoresizingMaskIntoConstraints = false;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView setAlwaysBounceVertical:NO];
    self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.scrollViewContentWrapper = [[UIView alloc] init];
    self.scrollViewContentWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.scrollViewContentWrapper];
    
    self.stackView = [self newStackView];
    [self.scrollViewContentWrapper addSubview:self.stackView];
    
    self.view.translatesAutoresizingMaskIntoConstraints = false;
    self.view.backgroundColor = [UIColor clearColor];
    
    NSDictionary *viewBindings = @{@"stackView": self.stackView,
                                   @"scrollView": self.scrollView,
                                   @"scrollViewContentWrapper": self.scrollViewContentWrapper};
    
    [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    
    [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollViewContentWrapper]|"
                                                                      options:0
                                                                      metrics:[BTUIKAppearance metrics]
                                                                        views:viewBindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollViewContentWrapper(scrollView)]|"
                                                                      options:0
                                                                      metrics:[BTUIKAppearance metrics]
                                                                        views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[stackView]|"
                                                                      options:0
                                                                      metrics:[BTUIKAppearance metrics]
                                                                        views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(VERTICAL_SECTION_SPACE)-[stackView]-(VERTICAL_FORM_SPACE_TIGHT)-|"
                                                                      options:0
                                                                      metrics:[BTUIKAppearance metrics]
                                                                        views:viewBindings]];
    
    NSLayoutConstraint *heightConstraint;
    self.vaultedPaymentsHeader = [self sectionHeaderLabelWithString:@"Recent"];
    self.vaultedPaymentsHeader.translatesAutoresizingMaskIntoConstraints = NO;

    self.vaultedPaymentsLabelContainerStackView = [self newStackView];
    self.vaultedPaymentsLabelContainerStackView.layoutMargins = UIEdgeInsetsMake(0, [BTUIKAppearance horizontalFormContentPadding], 0, [BTUIKAppearance horizontalFormContentPadding]);
    self.vaultedPaymentsLabelContainerStackView.layoutMarginsRelativeArrangement = true;

    [self.vaultedPaymentsLabelContainerStackView addArrangedSubview:self.vaultedPaymentsHeader];
    [self.stackView addArrangedSubview:self.vaultedPaymentsLabelContainerStackView];

    //[self addSpacerToStackView:self.stackView beforeView:self.vaultedPaymentsLabelContainerStackView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection: UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[BTUIPaymentMethodCollectionViewCell class] forCellWithReuseIdentifier:@"BTUIPaymentMethodCollectionViewCellIdentifier"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    heightConstraint = [self.collectionView.heightAnchor constraintEqualToConstant:SAVED_PAYMENT_METHODS_COLLECTION_HEIGHT + [BTUIKAppearance verticalFormSpace]];
    // Setting the prioprity is necessary to avoid autolayout errors when UIStackView rotates
    heightConstraint.priority = UILayoutPriorityDefaultHigh;
    heightConstraint.active = YES;
    [self.stackView addArrangedSubview:self.collectionView];

    self.paymentOptionsHeader = [self sectionHeaderLabelWithString:@"Other"];
    self.paymentOptionsHeader.translatesAutoresizingMaskIntoConstraints = NO;

    self.paymentOptionsLabelContainerStackView = [self newStackView];
    self.paymentOptionsLabelContainerStackView.layoutMargins = UIEdgeInsetsMake(0, [BTUIKAppearance horizontalFormContentPadding], [BTUIKAppearance verticalFormSpaceTight], [BTUIKAppearance horizontalFormContentPadding]);
    self.paymentOptionsLabelContainerStackView.layoutMarginsRelativeArrangement = true;

    [self.paymentOptionsLabelContainerStackView addArrangedSubview:self.paymentOptionsHeader];
    [self.stackView addArrangedSubview:self.paymentOptionsLabelContainerStackView];
    
    self.paymentOptionsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.paymentOptionsTableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
    self.paymentOptionsTableView.backgroundColor = [UIColor clearColor];
    [self.paymentOptionsTableView registerClass:[BTDropInPaymentSeletionCell class] forCellReuseIdentifier:@"BTDropInPaymentSeletionCell"];
    self.paymentOptionsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.paymentOptionsTableView.delegate = self;
    self.paymentOptionsTableView.dataSource = self;
    self.paymentOptionsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.paymentOptionsTableView setAlwaysBounceVertical:NO];

    [self.stackView addArrangedSubview:self.paymentOptionsTableView];
    
    [self loadConfiguration];
}

- (void)loadConfiguration {
    [self showLoadingScreen:YES animated:NO];
    self.stackView.hidden = YES;
    [super loadConfiguration];
    
}

- (void)dealloc {
    [self.paymentOptionsTableView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary <NSString *, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self.paymentOptionsTableView removeConstraints:self.paymentOptionsTableView.constraints];
        NSLayoutConstraint *heightConstraint = [self.paymentOptionsTableView.heightAnchor constraintEqualToConstant:self.paymentOptionsTableView.contentSize.height];
        // Setting the prioprity is necessary to avoid autolayout errors when UIStackView rotates
        heightConstraint.priority = UILayoutPriorityDefaultHigh;
        heightConstraint.active = YES;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)configurationLoaded:(__unused BTConfiguration *)configuration error:(NSError *)error {
    NSMutableArray *activePaymentOptions = [@[] mutableCopy];
    if (!error) {
        [self fetchPaymentMethodsOnCompletion:^{
            if ([[BTTokenizationService sharedService] isTypeAvailable:@"PayPal"] && [self.configuration.json[@"paypalEnabled"] isTrue]) {
                
                [activePaymentOptions addObject:@(BTUIKPaymentOptionTypePayPal)];
            }
            
            BTJSON *venmoAccessToken = self.configuration.json[@"payWithVenmo"][@"accessToken"];
            if ([[BTTokenizationService sharedService] isTypeAvailable:@"Venmo"] && venmoAccessToken.isString) {
                NSURLComponents *components = [NSURLComponents componentsWithString:@"com.venmo.touch.v2://x-callback-url/vzero/auth"];
                BOOL isVenmoAppInstalled = [[UIApplication sharedApplication] canOpenURL:components.URL];
                if (isVenmoAppInstalled) {
                    [activePaymentOptions addObject:@(BTUIKPaymentOptionTypeVenmo)];
                }
            }

            // Always add Cards
            [activePaymentOptions addObject:@(BTUIKPaymentOptionTypeUnknown)];
            
            BTJSON *applePayConfiguration = self.configuration.json[@"applePay"];
            if ([applePayConfiguration[@"status"] isString] && ![[applePayConfiguration[@"status"] asString] isEqualToString:@"off"] && self.dropInRequest.showApplePayPaymentOption) {
                [activePaymentOptions addObject:@(BTUIKPaymentOptionTypeApplePay)];
            }
            
            self.paymentOptionsData = [activePaymentOptions copy];
            [self.collectionView reloadData];
            [self.paymentOptionsTableView reloadData];
            if (self.paymentMethodNonces.count == 0) {
                self.collectionView.hidden = YES;
                self.vaultedPaymentsHeader.hidden = YES;
                self.paymentOptionsLabelContainerStackView.hidden = YES;
                self.vaultedPaymentsLabelContainerStackView.hidden = YES;
            } else {
                self.collectionView.hidden = NO;
                self.vaultedPaymentsHeader.hidden = NO;
                self.paymentOptionsLabelContainerStackView.hidden = NO;
                self.vaultedPaymentsLabelContainerStackView.hidden = NO;
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            }
            [self showLoadingScreen:NO animated:YES];
            self.stackView.hidden = NO;
        }];
    }
}

#pragma mark - Helpers

- (void)fetchPaymentMethodsOnCompletion:(void(^)())completionBlock {
    if (!self.apiClient.clientToken) {
        self.paymentMethodNonces = @[];
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [self.apiClient fetchPaymentMethodNonces:NO completion:^(NSArray<BTPaymentMethodNonce *> *paymentMethodNonces, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (error) {
            // no action
        } else {
            self.paymentMethodNonces = [paymentMethodNonces copy];
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    if (self.presentingViewController != nil) {
        return [self.presentingViewController prefersStatusBarHidden];
    }
    return NO;
}

- (UIStackView *)newStackView {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis  = UILayoutConstraintAxisVertical;
    stackView.distribution  = UIStackViewDistributionFill;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 0;
    return stackView;
}

- (UILabel *)sectionHeaderLabelWithString:(NSString*)string {
    UILabel *sectionLabel = [UILabel new];
    sectionLabel.text = [string uppercaseString];
    sectionLabel.textAlignment = NSTextAlignmentNatural;
    [BTUIKAppearance styleSystemLabelSecondary:sectionLabel];
    return sectionLabel;
}

- (UIView *)addSpacerToStackView:(UIStackView *)stackView beforeView:(UIView *)view {
    NSInteger indexOfView = [stackView.arrangedSubviews indexOfObject:view];
    if (indexOfView != NSNotFound) {
        UIView* spacer = [[UIView alloc] init];
        spacer.translatesAutoresizingMaskIntoConstraints = NO;
        [stackView insertArrangedSubview:spacer atIndex:indexOfView];
        NSLayoutConstraint* heightConstraint = [spacer.heightAnchor constraintEqualToConstant:22];
        heightConstraint.priority = UILayoutPriorityDefaultHigh;
        heightConstraint.active = true;
        return spacer;
    }
    return nil;
}

#pragma mark - Protocol conformance
#pragma mark UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(__unused UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView numberOfItemsInSection:(__unused NSInteger)section {
    return [self.paymentMethodNonces count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BTUIPaymentMethodCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BTUIPaymentMethodCollectionViewCellIdentifier" forIndexPath:indexPath];
    BTPaymentMethodNonce *paymentInfo = self.paymentMethodNonces[indexPath.row];
    cell.paymentMethodNonce = paymentInfo;
    NSString *typeString = paymentInfo.type;
    NSMutableAttributedString *typeWithDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", paymentInfo.localizedDescription ?: @""]];
    if ([paymentInfo isKindOfClass:[BTCardNonce class]]) {
        typeWithDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"••• ••%@", ((BTCardNonce*)paymentInfo).lastTwo ?: @""]];
    }
    cell.highlighted = NO;
    cell.descriptionLabel.attributedText = typeWithDescription;
    cell.titleLabel.text = [BTUIKViewUtil nameForPaymentMethodType:[BTUIKViewUtil paymentOptionTypeForPaymentInfoType:typeString]];
    cell.paymentOptionCardView.paymentOptionType = [BTUIKViewUtil paymentOptionTypeForPaymentInfoType:typeString];
    return cell;
}

- (CGSize)collectionView:(__unused UICollectionView *)collectionView layout:(__unused UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(__unused NSIndexPath *)indexPath {
    return CGSizeMake(SAVED_PAYMENT_METHODS_COLLECTION_WIDTH, SAVED_PAYMENT_METHODS_COLLECTION_HEIGHT);
}

#pragma mark collection view cell paddings

- (UIEdgeInsets)collectionView:(__unused UICollectionView*)collectionView layout:(__unused UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(__unused NSInteger)section {
    return UIEdgeInsetsMake(0, [BTUIKAppearance horizontalFormContentPadding], 0, [BTUIKAppearance horizontalFormContentPadding]);
}

- (CGFloat)collectionView:(__unused UICollectionView *)collectionView layout:(__unused UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(__unused NSInteger)section {
    return SAVED_PAYMENT_METHODS_COLLECTION_SPACING;
}

- (CGFloat)collectionView:(__unused UICollectionView *)collectionView layout:(__unused UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(__unused NSInteger)section {
    return SAVED_PAYMENT_METHODS_COLLECTION_SPACING;
}

- (void)collectionView:(__unused UICollectionView *)collectionView didSelectItemAtIndexPath:(__unused NSIndexPath *)indexPath {
    BTUIPaymentMethodCollectionViewCell *cell = (BTUIPaymentMethodCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate) {
        [self.delegate selectionCompletedWithPaymentMethodType:[BTUIKViewUtil paymentOptionTypeForPaymentInfoType:cell.paymentMethodNonce.type] nonce:cell.paymentMethodNonce error:nil];
    }
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"BTDropInPaymentSeletionCell";

    BTDropInPaymentSeletionCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    BTUIKPaymentOptionType option = ((NSNumber*)self.paymentOptionsData[indexPath.row]).intValue;

    cell.label.text = [BTUIKViewUtil nameForPaymentMethodType:option];
    if (option == BTUIKPaymentOptionTypeUnknown) {
        cell.label.text = @"Credit or Debit Card";
    }
    cell.iconView.paymentOptionType = option;
    cell.type = option;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTDropInPaymentSeletionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.type == BTUIKPaymentOptionTypeUnknown) {
        if ([self.delegate respondsToSelector:@selector(showCardForm:)]){
            [self.delegate performSelector:@selector(showCardForm:) withObject:self];
        }
    } else if (cell.type == BTUIKPaymentOptionTypePayPal) {
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        if (self.delegate != nil) {
            options[BTTokenizationServiceViewPresentingDelegateOption] = self.delegate;
        }
        if (self.dropInRequest.additionalPayPalScopes != nil) {
            options[BTTokenizationServicePayPalScopesOption] = self.dropInRequest.additionalPayPalScopes;
        }
        
        [[BTTokenizationService sharedService] tokenizeType:@"PayPal" options:options withAPIClient:self.apiClient completion:^(BTPaymentMethodNonce * _Nullable paymentMethodNonce, NSError * _Nullable error) {
            if (self.delegate && paymentMethodNonce != nil) {
                BTUIKPaymentOptionType type = [BTUIKViewUtil paymentOptionTypeForPaymentInfoType:paymentMethodNonce.type];
                [self.delegate selectionCompletedWithPaymentMethodType:type nonce:paymentMethodNonce error:error];
            }
        }];
        
    } else if (cell.type == BTUIKPaymentOptionTypeVenmo) {
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        if (self.delegate != nil) {
            options[BTTokenizationServiceViewPresentingDelegateOption] = self.delegate;
        }
        [[BTTokenizationService sharedService] tokenizeType:@"Venmo" options:options withAPIClient:self.apiClient completion:^(BTPaymentMethodNonce * _Nullable paymentMethodNonce, NSError * _Nullable error) {
            if (self.delegate && paymentMethodNonce != nil) {
                [self.delegate selectionCompletedWithPaymentMethodType:BTUIKPaymentOptionTypeVenmo nonce:paymentMethodNonce error:error];
            }
        }];
    } else if(cell.type == BTUIKPaymentOptionTypeApplePay) {
        if (self.delegate) {
            [self.delegate selectionCompletedWithPaymentMethodType:BTUIKPaymentOptionTypeApplePay nonce:nil error:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return [self.paymentOptionsData count];
}

@end
