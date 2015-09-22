#import "BraintreeDemoBraintreeDataViewController.h"
#import "BTFraudData.h"
#import <CoreLocation/CLLocationManager.h>
#import <PureLayout/PureLayout.h>

@interface BraintreeDemoBraintreeDataViewController ()
/// Retain BTFraudData for entire lifecycle of view controller
@property (nonatomic, strong) BTFraudData *data;
@property (nonatomic, strong) UILabel *dataLabel;
@end

@implementation BraintreeDemoBraintreeDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"BTData Fraud Protection";

    UIButton *initializeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [initializeButton setTitle:@"Initialize BTData" forState:UIControlStateNormal];
    [initializeButton addTarget:self action:@selector(tappedInitialize) forControlEvents:UIControlEventTouchUpInside];

    UIButton *collectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [collectButton setTitle:@"Collect Data" forState:UIControlStateNormal];
    [collectButton addTarget:self action:@selector(tappedCollect) forControlEvents:UIControlEventTouchUpInside];

    UIButton *obtainLocationPermissionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [obtainLocationPermissionButton setTitle:@"Obtain Location Permission" forState:UIControlStateNormal];
    [obtainLocationPermissionButton addTarget:self action:@selector(tappedRequestLocationAuthorization:) forControlEvents:UIControlEventTouchUpInside];

    self.dataLabel = [[UILabel alloc] init];
    self.dataLabel.numberOfLines = 0;

    [self.view addSubview:initializeButton];
    [self.view addSubview:collectButton];
    [self.view addSubview:obtainLocationPermissionButton];
    [self.view addSubview:self.dataLabel];

    [initializeButton autoCenterInSuperviewMargins];
    [initializeButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:collectButton withOffset:-10];
    [collectButton autoAlignAxis:ALAxisVertical toSameAxisOfView:initializeButton];

    [obtainLocationPermissionButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    [obtainLocationPermissionButton autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
    
    [self.dataLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:collectButton];
    [self.dataLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.dataLabel autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.dataLabel autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
}

- (IBAction)tappedInitialize
{
    self.data = [[BTFraudData alloc] initWithEnvironment:BTFraudDataEnvironmentSandbox];
    self.progressBlock([NSString stringWithFormat:@"Initialized data %@", self.data]);
}

- (IBAction)tappedCollect
{
    [self.data collectFraudData:^(NSString * _Nullable deviceData, NSError * _Nullable error) {
        if (error) {
            self.progressBlock(@"Error collecting data");
            NSLog(@"Error collecting data: %@", error);
            return;
        }
        self.progressBlock([NSString stringWithFormat:@"Collected data!"]);
        self.dataLabel.text = deviceData;
    }];
}

- (IBAction)tappedRequestLocationAuthorization:(__unused id)sender {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
}

@end
