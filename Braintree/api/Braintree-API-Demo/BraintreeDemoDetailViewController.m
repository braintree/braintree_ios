#import "BraintreeDemoDetailViewController.h"

void *BraintreeDemoDetailViewControllerDetailTextDidChange = &BraintreeDemoDetailViewControllerDetailTextDidChange;

const NSInteger BraintreeDemoDetailViewControllerSectionIndexResult = 0;
const NSInteger BraintreeDemoDetailViewControllerSectionIndexError = 1;

NSString * BraintreeDemoDetailViewControllerErrorPrototypeCell = @"ErrorCell";
NSString * BraintreeDemoDetailViewControllerResultPropertyPrototypeCell = @"ResultPropertyCell";

@interface BraintreeDemoDetailViewController ()
- (void)configureView;

@property (nonatomic, strong) id result;
@property (nonatomic, strong) NSError *error;

@end

@implementation BraintreeDemoDetailViewController

#pragma mark - Managing the detail item

- (void)setSelectedOperation:(id)aSelectedOperation
{
    _selectedOperation = aSelectedOperation;


    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_selectedOperation performWithCompletionBlock:^(id result, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.result = result;
        self.error = error;

        [self configureView];
    }];
}

- (void)configureView
{
    if (self.selectedOperation.name) {
        self.title = self.selectedOperation.name;
    }

    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureView];
}


#pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case BraintreeDemoDetailViewControllerSectionIndexError:
            return 1;
            break;
        case BraintreeDemoDetailViewControllerSectionIndexResult:
            if ([self.result isKindOfClass:[BTCard class]]) {
                return 5;
            } else if ([self.result isKindOfClass:[BTPayPalAccount class]]) {
                return 3;
            } else if ([self.result isKindOfClass:[NSString class]]) {
                return 1;
            } else if ([self.result respondsToSelector:@selector(objectAtIndex:)] && [self.result respondsToSelector:@selector(count)]) {
                return [self.result count];
            } else {
                return 0;
            }
            break;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case BraintreeDemoDetailViewControllerSectionIndexResult:
            return @"Result";
        case BraintreeDemoDetailViewControllerSectionIndexError:
            return @"Error";
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    switch (indexPath.section) {
        case BraintreeDemoDetailViewControllerSectionIndexResult:
            cell = [tableView dequeueReusableCellWithIdentifier:BraintreeDemoDetailViewControllerResultPropertyPrototypeCell];
            if ([self.result isKindOfClass:[BTCard class]]) {
                {
                    BTCard *card = self.result;
                    switch (indexPath.row) {
                        case 0:
                            cell.textLabel.text = @"nonce";
                            cell.detailTextLabel.text = card.nonce;
                            break;
                        case 1:
                            cell.textLabel.text = @"isLocked";
                            cell.detailTextLabel.text = card.isLocked ? @"YES" : @"NO";
                            break;
                        case 2:
                            cell.textLabel.text = @"type";
                            cell.detailTextLabel.text = card.typeString;
                            break;
                        case 3:
                            cell.textLabel.text = @"lastTwo";
                            cell.detailTextLabel.text = card.lastTwo;
                            break;
                        case 4:
                            cell.textLabel.text = @"challenge";
                            cell.detailTextLabel.text = [[card.challengeQuestions allObjects] componentsJoinedByString:@", "];
                            break;
                        default:
                            break;
                    }
                }
            } else if ([self.result isKindOfClass:[BTPayPalAccount class]]) {
                {
                    BTPayPalAccount *card = self.result;
                    switch (indexPath.row) {
                        case 0:
                            cell.textLabel.text = @"nonce";
                            cell.detailTextLabel.text = card.nonce;
                            break;
                        case 1:
                            cell.textLabel.text = @"isLocked";
                            cell.detailTextLabel.text = card.isLocked ? @"YES" : @"NO";
                            break;
                        case 2:
                            cell.textLabel.text = @"email";
                            cell.detailTextLabel.text = card.email;
                            break;
                        default:
                            break;
                    }
                }
            } else if ([self.result isKindOfClass:[NSString class]]) {
                cell.textLabel.text = NSStringFromClass([self.result class]);
                cell.detailTextLabel.text = [self.result description];
            } else if ([self.result respondsToSelector:@selector(objectAtIndex:)] && [self.result respondsToSelector:@selector(count)]) {
                {
                    id value = self.result[indexPath.row];
                    cell.textLabel.text = NSStringFromClass([value class]);
                    cell.detailTextLabel.text = [value description];
                }
            } else {
                NSLog(@"Warning: Rendering (%@) is not implemented. Rendering objects of type %@ is not implemented by %@", self.result, [self.result class], [self class]);
            }

            break;
        case BraintreeDemoDetailViewControllerSectionIndexError:
            cell = [tableView dequeueReusableCellWithIdentifier:BraintreeDemoDetailViewControllerErrorPrototypeCell];
            cell.textLabel.text = [self.error description];
            break;
    }
    
    return cell;
}

@end
