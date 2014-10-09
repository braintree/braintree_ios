#import "BraintreeDemoMasterViewController.h"
#import "BraintreeDemoDetailViewController.h"
#import "BraintreeDemoOperationManager.h"

@interface BraintreeDemoMasterViewController ()
@property (nonatomic, strong) NSArray *operations;
@property (nonatomic, strong) BraintreeDemoOperationManager *operationManager;
@end

@implementation BraintreeDemoMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.operationManager = [BraintreeDemoOperationManager manager];

    self.operations = @[
                 [self.operationManager clientVersionOperation],
                 [self.operationManager reinitializeClientOperation],
                 [self.operationManager fetchPaymentMethodsOperation],
                 [self.operationManager saveCardOperation],
                 [self.operationManager saveInvalidCardOperation],
                 [self.operationManager savePayPalPaymentMethodOperation],
                 [self.operationManager postAnalyticsEventOperation]
                 ];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"pushShowDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BraintreeDemoClientOperation *operation = self.operations[indexPath.row];
        [[segue destinationViewController] setSelectedOperation:operation];
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"API Operations";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.operations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    BraintreeDemoClientOperation *object = self.operations[indexPath.row];
    cell.textLabel.text = object.name;
    return cell;
}

@end
