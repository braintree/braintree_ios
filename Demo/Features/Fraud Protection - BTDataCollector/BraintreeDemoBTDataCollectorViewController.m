#import "BraintreeDemoBTDataCollectorViewController.h"
@import BraintreeDataCollector;
@import PayPalDataCollector;
@import CoreLocation;

@interface BraintreeDemoBTDataCollectorViewController () <BTDataCollectorDelegate>
/// Retain BTDataCollector for entire lifecycle of view controller
@property (nonatomic, strong) BTDataCollector *dataCollector;
@property (nonatomic, strong) UILabel *dataLabel;
@property (nonatomic, strong) BTAPIClient *apiClient;
@end

@implementation BraintreeDemoBTDataCollectorViewController

- (instancetype)initWithAuthorization:(NSString *)authorization {
    if (self = [super initWithAuthorization:authorization]) {
        _apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"BTDataCollector Protection", nil);

    UIButton *collectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [collectButton setTitle:NSLocalizedString(@"Collect All Data", nil) forState:UIControlStateNormal];
    [collectButton addTarget:self
                      action:@selector(tappedCollect)
            forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *collectKountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [collectKountButton setTitle:NSLocalizedString(@"Collect Kount Data", nil) forState:UIControlStateNormal];
    [collectKountButton addTarget:self
                           action:@selector(tappedCollectKount)
                 forControlEvents:UIControlEventTouchUpInside];

    UIButton *collectDysonButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [collectDysonButton setTitle:NSLocalizedString(@"Collect PayPal Data", nil) forState:UIControlStateNormal];
    [collectDysonButton addTarget:self
                           action:@selector(tappedCollectDyson)
                 forControlEvents:UIControlEventTouchUpInside];

    self.dataLabel = [[UILabel alloc] init];
    self.dataLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dataLabel.numberOfLines = 0;

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[collectButton,
                                                                             collectKountButton,
                                                                             collectDysonButton,
                                                                             self.dataLabel]];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;

    [self.view addSubview:stackView];

    UIButton *obtainLocationPermissionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    obtainLocationPermissionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [obtainLocationPermissionButton setTitle:NSLocalizedString(@"Obtain Location Permission", nil) forState:UIControlStateNormal];
    [obtainLocationPermissionButton addTarget:self
                                       action:@selector(tappedRequestLocationAuthorization:)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:obtainLocationPermissionButton];

    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:100.0],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [obtainLocationPermissionButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10.0],
        [obtainLocationPermissionButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];
    
    self.dataCollector = [[BTDataCollector alloc] initWithAPIClient:self.apiClient];
    self.dataCollector.delegate = self;
}

- (IBAction)tappedCollect
{    self.progressBlock(@"Started collecting all data...");
    [self.dataCollector collectDeviceData:^(NSString * _Nonnull deviceData) {
        self.dataLabel.text = deviceData;
    }];
}

- (IBAction)tappedCollectKount {
    self.progressBlock(@"Started collecting Kount data...");
    [self.dataCollector collectCardFraudData:^(NSString * _Nonnull deviceData) {
        self.dataLabel.text = deviceData;
    }];
}

- (IBAction)tappedCollectDyson {
    self.dataLabel.text = [PPDataCollector collectPayPalDeviceData];
    self.progressBlock(@"Collected PayPal clientMetadataID!");
}

- (IBAction)tappedRequestLocationAuthorization:(__unused id)sender {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
}

#pragma mark - BTDataCollectorDelegate

/// The collector has started.
- (void)dataCollectorDidStart:(__unused BTDataCollector *)dataCollector {
    self.progressBlock(@"Data collector did start...");
}

/// The collector finished successfully.
- (void)dataCollectorDidComplete:(__unused BTDataCollector *)dataCollector {
    self.progressBlock(@"Data collector did complete.");
}

/// An error occurred.
///
/// @param error Triggering error
- (void)dataCollector:(__unused BTDataCollector *)dataCollector didFailWithError:(NSError *)error {
    self.progressBlock(@"Error collecting data.");
    NSLog(@"Error collecting data. error = %@", error);
}

@end
