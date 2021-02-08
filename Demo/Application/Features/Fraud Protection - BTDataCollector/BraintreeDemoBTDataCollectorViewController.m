#import "BraintreeDemoBTDataCollectorViewController.h"
@import BraintreeDataCollector;
@import PayPalDataCollector;
@import CoreLocation;

@interface BraintreeDemoBTDataCollectorViewController ()

/// Retain BTDataCollector for entire lifecycle of view controller
@property (nonatomic, strong) BTDataCollector *dataCollector;
@property (nonatomic, strong) UILabel *dataLabel;
@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation BraintreeDemoBTDataCollectorViewController

- (instancetype)initWithAuthorization:(NSString *)authorization {
    if (self = [super initWithAuthorization:authorization]) {
        _apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
        _locationManager = [CLLocationManager new];
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

    UIButton *collectPayPalButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [collectPayPalButton setTitle:NSLocalizedString(@"Collect PayPal Data", nil) forState:UIControlStateNormal];
    [collectPayPalButton addTarget:self
                            action:@selector(tappedCollectPayPal)
                  forControlEvents:UIControlEventTouchUpInside];

    self.dataLabel = [[UILabel alloc] init];
    self.dataLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dataLabel.numberOfLines = 0;

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[collectButton,
                                                                             collectPayPalButton,
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
}

- (IBAction)tappedCollect {
    self.progressBlock(@"Started collecting all data...");
    [self.dataCollector collectDeviceData:^(NSString * _Nonnull deviceData) {
        self.dataLabel.text = deviceData;
        self.progressBlock(@"Collected all device data!");
    }];
}

- (IBAction)tappedCollectPayPal {
    self.dataLabel.text = [PPDataCollector collectPayPalDeviceData];
    self.progressBlock(@"Collected PayPal clientMetadataID!");
}

- (IBAction)tappedRequestLocationAuthorization:(__unused id)sender {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestWhenInUseAuthorization];
            break;

        default:
            self.progressBlock(@"Location authorization requested previously. Update authorization in Settings app.");
            break;
    }
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
