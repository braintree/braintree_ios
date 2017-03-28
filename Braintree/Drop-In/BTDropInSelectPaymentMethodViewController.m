#import "BTDropInSelectPaymentMethodViewController.h"
#import "BTDropInUtil.h"
#import "BTUIViewUtil.h"
#import "BTUI.h"
#import "BTDropInViewController.h"
#import "BTDropInLocalizedString.h"
#import "BTUILocalizedString.h"

@interface BTDropInSelectPaymentMethodViewController ()

@end

@implementation BTDropInSelectPaymentMethodViewController

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAdd)];
        self.tableView.accessibilityIdentifier = @"Payment Methods Table";
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark -

- (void)didTapAdd {
    [self.delegate selectPaymentMethodViewControllerDidRequestNew:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section
{
    return [self.paymentMethods count] ?: 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *paymentMethodCellIdentifier = @"paymentMethodCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paymentMethodCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:paymentMethodCellIdentifier];
    }

    BTPaymentMethod *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
    if ([paymentMethod isKindOfClass:[BTPayPalPaymentMethod class]]) {
        BTPayPalPaymentMethod *payPalPaymentMethod = (BTPayPalPaymentMethod *)paymentMethod;
        NSString *typeString = BTUILocalizedString(PAYPAL_CARD_BRAND);
        NSMutableAttributedString *typeWithDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", typeString, (payPalPaymentMethod.description ?: @"")]];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlTitleFont range:NSMakeRange(0, [typeString length])];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlDetailFont range:NSMakeRange([typeString length], [payPalPaymentMethod.description length])];
        cell.textLabel.attributedText = typeWithDescription;


        BTUIVectorArtView *iconArt = [[BTUI braintreeTheme] vectorArtViewForPaymentMethodType:BTUIPaymentMethodTypePayPal];
        UIImage *icon = [iconArt imageOfSize:CGSizeMake(42, 23)];
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.imageView.image = icon;

    } else if([paymentMethod isKindOfClass:[BTCardPaymentMethod class]]) {
        BTCardPaymentMethod *card = (BTCardPaymentMethod *)paymentMethod;


        BTUIPaymentMethodType uiPaymentMethodType = [BTDropInUtil uiForCardType:card.type];
        NSString *typeString = [BTUIViewUtil nameForPaymentMethodType:uiPaymentMethodType];

        NSMutableAttributedString *typeWithDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", typeString, card.description]];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlTitleFont range:NSMakeRange(0, [typeString length])];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlDetailFont range:NSMakeRange([typeString length], [card.description length])];
        cell.textLabel.attributedText = typeWithDescription;

        BTUIPaymentMethodType uiType = [BTDropInUtil uiForCardType:card.type];
        BTUIVectorArtView *iconArt = [[BTUI braintreeTheme] vectorArtViewForPaymentMethodType:uiType];
        UIImage *icon = [iconArt imageOfSize:CGSizeMake(42, 23)];
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.imageView.image = icon;
    } else if ([paymentMethod isKindOfClass:[BTCoinbasePaymentMethod class]]) {
        BTCoinbasePaymentMethod *coinbasePaymentMethod = (BTCoinbasePaymentMethod *)paymentMethod;
        NSString *typeString = BTUILocalizedString(PAYMENT_METHOD_TYPE_COINBASE);
        NSMutableAttributedString *typeWithDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", typeString, (coinbasePaymentMethod.description ?: @"")]];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlTitleFont range:NSMakeRange(0, [typeString length])];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlDetailFont range:NSMakeRange([typeString length], [coinbasePaymentMethod.description length])];
        cell.textLabel.attributedText = typeWithDescription;


        BTUIVectorArtView *iconArt = [[BTUI braintreeTheme] vectorArtViewForPaymentMethodType:BTUIPaymentMethodTypeCoinbase];
        UIImage *icon = [iconArt imageOfSize:CGSizeMake(42, 23)];
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.imageView.image = icon;

    } else {
        cell.textLabel.text = [paymentMethod description];
        cell.imageView.image = nil;
    }


    cell.accessoryType = (indexPath.row == self.selectedPaymentMethodIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(__unused UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPaymentMethodIndex = indexPath.row;
    [self.tableView reloadData];
    [self.delegate selectPaymentMethodViewController:self didSelectPaymentMethodAtIndex:indexPath.row];
}

@end
