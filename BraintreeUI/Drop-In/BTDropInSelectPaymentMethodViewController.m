#import "BTDropInSelectPaymentMethodViewController.h"
#import "BTDropInUtil.h"
#import "BTUIViewUtil.h"
#import "BTUI.h"
#import "BTDropinViewController.h"
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

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return self.paymentMethodNonces.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *paymentMethodCellIdentifier = @"paymentMethodCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:paymentMethodCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:paymentMethodCellIdentifier];
    }

    BTPaymentMethodNonce *paymentInfo = self.paymentMethodNonces[indexPath.row];

    NSString *typeString = paymentInfo.type;
    NSMutableAttributedString *typeWithDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", typeString, paymentInfo.localizedDescription ?: @""]];
    [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlTitleFont range:NSMakeRange(0, [typeString length])];
    [typeWithDescription addAttribute:NSFontAttributeName value:self.theme.controlDetailFont range:NSMakeRange([typeString length], paymentInfo.localizedDescription.length)];
    cell.textLabel.attributedText = typeWithDescription;

    BTUIVectorArtView *iconArt = [[BTUI braintreeTheme] vectorArtViewForPaymentInfoType:paymentInfo.type];
    UIImage *icon = [iconArt imageOfSize:CGSizeMake(42, 23)];
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.imageView.image = icon;
    cell.accessoryType = (indexPath.row == self.selectedPaymentMethodIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(__unused UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPaymentMethodIndex = indexPath.row;
    [self.tableView reloadData];
    [self.delegate selectPaymentMethodViewController:self didSelectPaymentMethodAtIndex:indexPath.row];
}

@end
