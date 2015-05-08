#import <Braintree/BTData.h>

#import "BraintreeDemoBraintreeDataViewController.h"

#import <Braintree/BTClient.h>
#import <Braintree/BTClient+Offline.h>

#import <PureLayout/PureLayout.h>

@interface BraintreeDemoBraintreeDataViewController () <BTDataDelegate>

/// Retain BTData for entire lifecycle of view controller
@property (nonatomic, strong) BTData *data;

@property (nonatomic, strong) BTClient *client;
@end

@implementation BraintreeDemoBraintreeDataViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.client = [[BTClient alloc] initWithClientToken:clientToken];
    }
    return self;
}

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


    [self.view addSubview:initializeButton];
    [self.view addSubview:collectButton];
    [self.view addSubview:obtainLocationPermissionButton];

    [initializeButton autoCenterInSuperviewMargins];
    [initializeButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:collectButton withOffset:-10];
    [collectButton autoAlignAxis:ALAxisVertical toSameAxisOfView:initializeButton];

    [obtainLocationPermissionButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    [obtainLocationPermissionButton autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
}

- (IBAction)tappedInitialize
{
    self.data = [[BTData alloc] initWithClient:self.client
                                   environment:BTDataEnvironmentSandbox];
    self.data.delegate = self;
    self.progressBlock([NSString stringWithFormat:@"Initialized data %@", self.data]);
}

- (IBAction)tappedCollect
{
    NSString *deviceData = [self.data collectDeviceData];

    self.progressBlock([NSString stringWithFormat:@"Collected data %@", deviceData]);
}

- (IBAction)tappedRequestLocationAuthorization:(__unused id)sender {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
}

- (void)btDataDidStartCollectingData:(__unused BTData *)data
{
    self.progressBlock(@"BTData didStartCollectingData");

}

- (void)btDataDidComplete:(__unused BTData *)data
{
    self.progressBlock(@"BTData didComplete");
}

- (void)btData:(__unused BTData *)data didFailWithErrorCode:(__unused int)errorCode error:(NSError *)error
{
    self.progressBlock(error.localizedDescription);
}

@end
