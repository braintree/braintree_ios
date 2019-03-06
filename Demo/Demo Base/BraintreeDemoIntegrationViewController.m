#import "BraintreeDemoIntegrationViewController.h"
#import <InAppSettingsKit/IASKAppSettingsViewController.h>
#import <InAppSettingsKit/IASKSpecifierValuesViewController.h>
#import <InAppSettingsKit/IASKViewController.h>
#import <InAppSettingsKit/IASKSettingsReader.h>

@interface BraintreeDemoIntegrationViewController ()
@property (nonatomic, strong) IASKSpecifierValuesViewController *targetViewController;
@property (nonatomic, strong) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, strong) IASKSpecifier *specifier;
@end

@implementation BraintreeDemoIntegrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Integrations", nil);
    
    // Integrations table view
    self.targetViewController = [[IASKSpecifierValuesViewController alloc] init];
    self.appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
    self.appSettingsViewController.delegate = self;
    
    // Find the "Integration" specifier
    IASKSettingsReader *reader = self.appSettingsViewController.settingsReader;
    for (NSInteger section = 0; section < reader.numberOfSections; section++) {
        for (NSInteger row = 0; row < [reader numberOfRowsForSection:section]; row++) {
            IASKSpecifier *specifier = [reader specifierForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            if ([specifier.title isEqualToString:@"Integration"]) {
                self.specifier = specifier;
                break;
            }
        }
    }
    
    [self.targetViewController setCurrentSpecifier:self.specifier];
    self.targetViewController.settingsReader = reader;
    self.targetViewController.settingsStore = self.appSettingsViewController.settingsStore;
    IASK_IF_IOS7_OR_GREATER(self.targetViewController.view.tintColor = self.appSettingsViewController.view.tintColor;)
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
