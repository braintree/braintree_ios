#import "BTDropInBaseViewController.h"
#import "BTAPIClient_Internal.h"

@interface BTDropInBaseViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIView *activityIndicatorWrapperView;

@end

@implementation BTDropInBaseViewController

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient request:(BTDropInRequest *)request
{
    if (self = [super init]) {
        self.apiClient = [apiClient copyWithSource:apiClient.metadata.source integration:BTClientMetadataIntegrationDropIn2];
        _dropInRequest = request;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.activityIndicatorWrapperView = [[UIView alloc] init];
    self.activityIndicatorWrapperView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.activityIndicatorWrapperView.hidden = YES;
    [self.view addSubview:self.activityIndicatorWrapperView];
    self.activityIndicatorWrapperView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[activityWrapper]|" options:0 metrics:nil views:@{@"activityWrapper": self.activityIndicatorWrapperView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[activityWrapper]|" options:0 metrics:nil views:@{@"activityWrapper": self.activityIndicatorWrapperView}]];

    self.activityIndicatorView = [UIActivityIndicatorView new];
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.activityIndicatorView startAnimating];
    [self.activityIndicatorWrapperView addSubview:self.activityIndicatorView];
    [self.activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.activityIndicatorWrapperView.centerXAnchor].active = YES;
    [self.activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.activityIndicatorWrapperView.centerYAnchor].active = YES;
}

- (void)loadConfiguration {
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, __unused NSError *error) {
        self.configuration = configuration;
        [self configurationLoaded:configuration error:error];
    }];
}

- (void)showLoadingScreen:(BOOL)show animated:(BOOL)animated {
    if (show) {
        [self.view bringSubviewToFront:self.activityIndicatorWrapperView];
    }

    if (animated) {
        [UIView transitionWithView:self.activityIndicatorWrapperView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.activityIndicatorWrapperView.hidden = !show;
        } completion:nil];
    } else {
        self.activityIndicatorWrapperView.hidden = !show;
    }
}

- (void)configurationLoaded:(__unused BTConfiguration *)configuration error:(__unused NSError *)error {
    //Subclasses should override this method
}

@end
