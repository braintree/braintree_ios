#import "BraintreeDemoBTFraudDataViewController.h"
#import "BTFraudData.h"
#import <CoreLocation/CLLocationManager.h>
#import <PureLayout/PureLayout.h>

@interface BraintreeDemoBTFraudDataViewController ()
/// Retain BTFraudData for entire lifecycle of view controller
@property (nonatomic, strong) BTFraudData *data;
@property (nonatomic, strong) UILabel *dataLabel;
@end

@implementation BraintreeDemoBTFraudDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"BTFraudData Protection";

    UIButton *collectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [collectButton setTitle:@"Collect All Data" forState:UIControlStateNormal];
    [collectButton addTarget:self action:@selector(tappedCollect) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *collectKountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [collectKountButton setTitle:@"Collect Kount Data" forState:UIControlStateNormal];
    [collectKountButton addTarget:self action:@selector(tappedCollectKount) forControlEvents:UIControlEventTouchUpInside];

    UIButton *collectDysonButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [collectDysonButton setTitle:@"Collect Dyson Data" forState:UIControlStateNormal];
    [collectDysonButton addTarget:self action:@selector(tappedCollectDyson) forControlEvents:UIControlEventTouchUpInside];

    UIButton *obtainLocationPermissionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [obtainLocationPermissionButton setTitle:@"Obtain Location Permission" forState:UIControlStateNormal];
    [obtainLocationPermissionButton addTarget:self action:@selector(tappedRequestLocationAuthorization:) forControlEvents:UIControlEventTouchUpInside];

    self.dataLabel = [[UILabel alloc] init];
    self.dataLabel.numberOfLines = 0;

    [self.view addSubview:collectButton];
    [self.view addSubview:collectKountButton];
    [self.view addSubview:collectDysonButton];
    [self.view addSubview:obtainLocationPermissionButton];
    [self.view addSubview:self.dataLabel];

    [collectButton autoCenterInSuperviewMargins];
    [collectKountButton autoAlignAxis:ALAxisVertical toSameAxisOfView:collectButton];
    [collectDysonButton autoAlignAxis:ALAxisVertical toSameAxisOfView:collectButton];
    [collectKountButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:collectButton];
    [collectDysonButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:collectKountButton];

    [obtainLocationPermissionButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    [obtainLocationPermissionButton autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
    
    [self.dataLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:collectDysonButton];
    [self.dataLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.dataLabel autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.dataLabel autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
    
    self.data = [[BTFraudData alloc] initWithEnvironment:BTFraudDataEnvironmentSandbox];
}

- (IBAction)tappedCollect
{
    self.progressBlock(@"Started collecting all data...");
    self.dataLabel.text = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self.data collectFraudData:^(NSString * _Nullable deviceData, NSError * _Nullable error) {
#pragma clang diagnostic pop
        if (error) {
            self.progressBlock(@"Error collecting data");
            NSLog(@"Error collecting data: %@", error);
            return;
        }
        self.progressBlock(@"Collected data!");
        self.dataLabel.text = deviceData;
    }];
}

- (IBAction)tappedCollectKount {
    self.progressBlock(@"Started collecting Kount data...");
    self.dataLabel.text = nil;
    
    [self.data collectCardFraudData:^(NSString * _Nullable deviceData, NSError * _Nullable error) {
        if (error) {
            self.progressBlock(@"Error collecting data");
            NSLog(@"Error collecting data: %@", error);
            return;
        }
        self.progressBlock(@"Collected data!");
        self.dataLabel.text = deviceData;
    }];
}

- (IBAction)tappedCollectDyson {
    self.dataLabel.text = [BTFraudData payPalFraudID];
    self.progressBlock(@"Collected data!");
}

- (IBAction)tappedRequestLocationAuthorization:(__unused id)sender {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
}

@end
