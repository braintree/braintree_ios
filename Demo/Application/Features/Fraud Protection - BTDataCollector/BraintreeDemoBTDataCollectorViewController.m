#import "BraintreeDemoBTDataCollectorViewController.h"
#import "Demo-Swift.h"
@import BraintreeDataCollector;
@import CoreLocation;

@interface BraintreeDemoBTDataCollectorViewController ()

/// Retain BTDataCollector for entire lifecycle of view controller
@property (nonatomic, strong) BTDataCollector *dataCollector;
@property (nonatomic, strong) UILabel *dataLabel;
@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *kountMerchantID;

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
    
    self.kountMerchantID = @"60001";
    self.title = NSLocalizedString(@"BTDataCollector Protection", nil);

    UIButton *collectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [collectButton setTitle:NSLocalizedString(@"Collect All Data", nil) forState:UIControlStateNormal];
    [collectButton addTarget:self
                      action:@selector(tappedCollect)
            forControlEvents:UIControlEventTouchUpInside];

    self.dataLabel = [[UILabel alloc] init];
    self.dataLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.dataLabel.numberOfLines = 0;

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[collectButton,
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
    [self.dataCollector collectDeviceDataWithKountMerchantID:self.kountMerchantID :^(NSString * _Nullable deviceData, NSError * _Nullable error) {
        self.dataLabel.text = deviceData;
        self.progressBlock(@"Collected all device data!");
    }];
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
