#import "BraintreeDemoIntegrationViewController.h"
#import <InAppSettingsKit/IASKAppSettingsViewController.h>
#import <InAppSettingsKit/IASKSpecifierValuesViewController.h>
#import <InAppSettingsKit/IASKViewController.h>
#import <InAppSettingsKit/IASKSettingsReader.h>
#import <iOS-Slide-Menu/SlideNavigationController.h>

@interface BraintreeDemoIntegrationViewController ()
@property (nonatomic, strong) IASKSpecifierValuesViewController *targetViewController;
@property (nonatomic, strong) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, strong) IASKSpecifier *specifier;
@end

@implementation BraintreeDemoIntegrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Integrations";
    
    // Integrations table view
    self.targetViewController = [[IASKSpecifierValuesViewController alloc] init];
    self.appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
    self.appSettingsViewController.delegate = self;
    
    // Assume that "Integration" is the first row of the first section
    self.specifier  = [self.appSettingsViewController.settingsReader specifierForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.targetViewController setCurrentSpecifier:self.specifier];
    self.targetViewController.settingsReader = self.appSettingsViewController.settingsReader;
    self.targetViewController.settingsStore = self.appSettingsViewController.settingsStore;
    IASK_IF_IOS7_OR_GREATER(self.targetViewController.view.tintColor = self.appSettingsViewController.view.tintColor;)
    
    // Add table view to self
    SlideNavigationController *snc = [SlideNavigationController sharedInstance];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.targetViewController.view.frame = CGRectMake(snc.portraitSlideOffset, 0, self.view.bounds.size.width - snc.portraitSlideOffset, self.view.bounds.size.height);
    [self.targetViewController viewWillAppear:NO]; // required. not animated
    [self.view addSubview:self.targetViewController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appSettingChangedNotification:) name:kIASKAppSettingChanged object:nil];
}

- (void)appSettingChangedNotification:(NSNotification *)notification {
    SlideNavigationController *snc = [SlideNavigationController sharedInstance];
    if (snc.isMenuOpen) {
        [self.delegate integrationViewController:self didChangeAppSetting:notification.userInfo];
        [snc closeMenuWithCompletion:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
