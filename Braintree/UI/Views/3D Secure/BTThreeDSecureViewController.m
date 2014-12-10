#import "BTThreeDSecureViewController.h"
#import "BTURLUtils.h"

@interface BTThreeDSecureViewController () <UIWebViewDelegate>
@property (nonatomic, strong) BTThreeDSecureLookup *lookup;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation BTThreeDSecureViewController

- (instancetype)initWithLookup:(BTThreeDSecureLookup *)lookup {
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

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.lookup.acsURL];
    [request setHTTPMethod:@"POST"];
    NSDictionary *fields = @{ @"PaReq": self.lookup.PAReq,
                              @"TermUrl": self.lookup.termURL,
                              @"MD": self.lookup.nonce };
    [request setHTTPBody:[[BTURLUtils queryStringWithDictionary:fields] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setAllHTTPHeaderFields:@{ @"Accept": @"text/html", @"Content-Type": @"application/x-www-form-urlencoded"}];
    [self.webView loadRequest:request];

    [self.view addSubview:self.webView];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:@{ @"webView": self.webView }]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:@{ @"webView": self.webView }]];
}

- (void)didCompleteAuthentication:(__unused NSDictionary *)authResponse {
    if ([self.delegate respondsToSelector:@selector(threeDSecureViewController:didAuthenticateNonce:completion:)]) {
        [self.delegate threeDSecureViewController:self
                             didAuthenticateNonce:self.lookup.nonce
                                       completion:^(__unused BTThreeDSecureViewControllerCompletionStatus status) {
                                           if ([self.delegate respondsToSelector:@selector(threeDSecureViewControllerDidFinish:)]) {
                                               [self.delegate threeDSecureViewControllerDidFinish:self];
                                           }
                                       }];
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(__unused UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(__unused UIWebViewNavigationType)navigationType {
    if ([request.URL.path containsString:@"authentication_complete_frame"]) {
        NSString *rawAuthResponse = [BTURLUtils dictionaryForQueryString:request.URL.query][@"auth_response"];
        NSDictionary *authResponse = [NSJSONSerialization JSONObjectWithData:[rawAuthResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:0
                                                                       error:NULL];

        [self didCompleteAuthentication:authResponse];
        return NO;
    } else {
        return YES;
    }
}

@end
