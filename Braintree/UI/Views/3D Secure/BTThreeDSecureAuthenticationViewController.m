#import "BTThreeDSecureAuthenticationViewController.h"
#import "BTURLUtils.h"
#import "BTClient_Internal.h"
#import "UIColor+BTUI.h"
#import "BTThreeDSecureResponse.h"

@interface BTThreeDSecureAuthenticationViewController () <UIWebViewDelegate>
@property (nonatomic, strong) BTThreeDSecureLookupResult *lookup;
@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) UIBarButtonItem *goBackButton;
@property (nonatomic, strong) UIBarButtonItem *goForwardButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation BTThreeDSecureAuthenticationViewController

- (instancetype)initWithLookup:(BTThreeDSecureLookupResult *)lookup {
    if (!lookup.requiresUserAuthentication) {
        return nil;
    }

    self = [super init];
    if (self) {
        self.lookup = lookup;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.title = @"3D Secure";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(tappedCancel)];

    self.goBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Go Back" style:UIBarButtonItemStylePlain target:self action:@selector(tappedGoBack)];
    self.goBackButton.enabled = NO;
    self.goBackButton.accessibilityLabel = @"Go Back";
    self.goForwardButton = [[UIBarButtonItem alloc] initWithTitle:@"Go Forward" style:UIBarButtonItemStylePlain target:self action:@selector(tappedGoForward)];
    self.goForwardButton.enabled = NO;
    self.goBackButton.accessibilityLabel = @"Go Forward";

    self.toolbarItems = @[ self.goBackButton, self.goForwardButton, ];
    self.navigationController.toolbarHidden = NO;

    UIActivityIndicatorViewStyle style = [self.navigationController.navigationBar.tintColor bt_contrastingActivityIndicatorStyle];
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.accessibilityLabel = @"Progress View";
    [self.activityIndicatorView stopAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    NSMutableURLRequest *acsRequest = [NSMutableURLRequest requestWithURL:self.lookup.acsURL];
    [acsRequest setHTTPMethod:@"POST"];
    NSDictionary *fields = @{ @"PaReq": self.lookup.PAReq,
                              @"TermUrl": self.lookup.termURL,
                              @"MD": self.lookup.MD };
    [acsRequest setHTTPBody:[[BTURLUtils queryStringWithDictionary:fields] dataUsingEncoding:NSUTF8StringEncoding]];
    [acsRequest setAllHTTPHeaderFields:@{ @"Accept": @"text/html", @"Content-Type": @"application/x-www-form-urlencoded"}];
    [self.webView loadRequest:acsRequest];

    [self.view addSubview:self.webView];

    NSDictionary *views = @{ @"webView": self.webView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:views]];
}

- (void)didCompleteAuthentication:(BTThreeDSecureResponse *)response {
    if (response.success) {
        if ([self.delegate respondsToSelector:@selector(threeDSecureViewController:didAuthenticateCard:completion:)]) {
            [self.delegate threeDSecureViewController:self
                                  didAuthenticateCard:response.paymentMethod
                                           completion:^(__unused BTThreeDSecureViewControllerCompletionStatus status) {
                                               if ([self.delegate respondsToSelector:@selector(threeDSecureViewControllerDidFinish:)]) {
                                                   [self.delegate threeDSecureViewControllerDidFinish:self];
                                               }
                                           }];
        }
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        if (response.threeDSecureInfo) {
            userInfo[BTThreeDSecureInfoKey] = response.threeDSecureInfo;
        }
        if (response.errorMessage) {
            userInfo[NSLocalizedDescriptionKey] = response.errorMessage;
        }
        NSError *error = [NSError errorWithDomain:BTThreeDSecureErrorDomain
                                             code:BTThreeDSecureFailedAuthenticationErrorCode
                                         userInfo:userInfo];
        if ([self.delegate respondsToSelector:@selector(threeDSecureViewController:didFailWithError:)]) {
            [self.delegate threeDSecureViewController:self didFailWithError:error];
        }
        if ([self.delegate respondsToSelector:@selector(threeDSecureViewControllerDidFinish:)]) {
            [self.delegate threeDSecureViewControllerDidFinish:self];
        }
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(__unused UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(__unused UIWebViewNavigationType)navigationType {
    if ([request.URL.path containsString:@"authentication_complete_frame"]) {
        NSString *rawAuthResponse = [BTURLUtils dictionaryForQueryString:request.URL.query][@"auth_response"];
        NSDictionary *authResponseDictionary = [NSJSONSerialization JSONObjectWithData:[rawAuthResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:0
                                                                       error:NULL];

        BTThreeDSecureResponse *authResponse = [[BTThreeDSecureResponse alloc] init];
        authResponse.success = [authResponseDictionary[@"success"] boolValue];
        authResponse.threeDSecureInfo = authResponseDictionary[@"threeDSecureInfo"];

        NSDictionary *paymentMethodDictionary = authResponseDictionary[@"paymentMethod"];
        if ([paymentMethodDictionary isKindOfClass:[NSDictionary class]]) {
            authResponse.paymentMethod = [BTClient cardFromAPIResponseDictionary:paymentMethodDictionary];
        }
        authResponse.errorMessage = authResponseDictionary[@"error"][@"message"];

        [self didCompleteAuthentication:authResponse];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicatorView startAnimating];
    self.goBackButton.enabled = webView.canGoBack;
    self.goForwardButton.enabled = webView.canGoForward;
}

- (void)webViewDidFinishLoad:(__unused UIWebView *)webView {
    [self.activityIndicatorView stopAnimating];
}

#pragma mark User Interaction

- (void)tappedCancel {
    NSLog(@"[3DS] CANCELED");
}

- (void)tappedGoForward {
    NSLog(@"[3DS] Go Forward");
    [self.webView goForward];
}

- (void)tappedGoBack {
    NSLog(@"[3DS] Go Back");
    [self.webView goBack];
}

@end
