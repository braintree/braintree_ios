#import "BTDropInSelectPaymentMethodTableViewController.h"
#import "BTDropInUtil.h"
#import "BTUIPayPalMonogramColorView.h"
#import "BTUIViewUtil.h"
#import "BTUI.h"
#import "BTDropinViewController.h"

@interface BTDropInSelectPaymentMethodTableViewController () <BTDropInViewControllerDelegate>

@end

@implementation BTDropInSelectPaymentMethodTableViewController

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAdd)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didCancel)];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark -

- (void)didCancel {
    [self.delegate dropInSelectPaymentMethodTableViewControllerDidCancel:self];
}

- (void)didTapAdd {
    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc] initWithClient:self.client];
    dropInViewController.shouldDisplayPaymentMethodsOnFile = NO;
    dropInViewController.shouldHideCallToAction = YES;
    dropInViewController.delegate = self;
    [self.navigationController pushViewController:dropInViewController animated:YES];
}

#pragma mark - BTDropInViewController delegate

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.delegate dropInSelectPaymentMethodTableViewController:self didCreatePaymentMethod:paymentMethod];
}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didFailWithError:(__unused NSError *)error {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section
{
    return [self.paymentMethods count] ?: 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentMethodCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"paymentMethodCell"];
    }

    BTPaymentMethod *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
    if ([paymentMethod isKindOfClass:[BTPayPalAccount class]]) {
        BTPayPalAccount *payPalAccount = (BTPayPalAccount *)paymentMethod;
        NSString *typeString = @"PayPal";
        NSMutableAttributedString *typeWithDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", typeString, (payPalAccount.description ?: @"")]];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlTitleFont range:NSMakeRange(0, [typeString length])];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlDetailFont range:NSMakeRange([typeString length], [payPalAccount.description length])];
        cell.textLabel.attributedText = typeWithDescription;

        BTUIPayPalMonogramColorView *ppMonogram = [[BTUIPayPalMonogramColorView alloc] init];
        UIImage *icon = [ppMonogram imageOfSize:CGSizeMake(42, 23)];
        cell.imageView.image = icon;
    } else if([paymentMethod isKindOfClass:[BTCard class]]) {
        BTCard *card = (BTCard *)paymentMethod;
        NSMutableAttributedString *typeWithDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", card.typeString, card.description]];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlTitleFont range:NSMakeRange(0, [card.typeString length])];
        [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlDetailFont range:NSMakeRange([card.typeString length], [card.description length])];
        cell.textLabel.attributedText = typeWithDescription;

        BTUIPaymentMethodType uiType = [BTDropInUtil uiForCardType:card.type];
        BTUIVectorArtView *iconArt = [[BTUI braintreeTheme] vectorArtViewForPaymentMethodType:uiType];
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
    [self.delegate dropInSelectPaymentMethodTableViewController:self didSelectPaymentMethodAtIndex:indexPath.row];
}

@end
