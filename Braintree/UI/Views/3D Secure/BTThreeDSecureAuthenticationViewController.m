#import "BTThreeDSecureAuthenticationViewController.h"
#import "BTURLUtils.h"
#import "BTClient_Internal.h"
#import "UIColor+BTUI.h"
#import "BTThreeDSecureResponse.h"
#import "BTThreeDSecurePopupWebViewViewController.h"

static NSString *BTThreeDSecureAuthenticationViewControllerPopupDummyURLScheme = @"popup";

@interface BTThreeDSecureAuthenticationViewController () <UIWebViewDelegate, BTThreeDSecurePopupWebViewViewControllerDelegate>
@property (nonatomic, strong) BTThreeDSecureLookupResult *lookup;
@property (nonatomic, strong) UIWebView *webView;
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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(tappedCancel)];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
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

- (BOOL)webView:(__unused UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked && [self detectPopupLinkForURL:request.URL]) {
        [self openPopupWithURL:[self extractPopupLinkURL:request.URL]];
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked && [self detectPopupCloseLinkForURL:request.URL]) {
        [self openPopupWithURL:[self extractPopupLinkURL:request.URL]];
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeFormSubmitted && [request.URL.path containsString:@"authentication_complete_frame"]) {
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
    [self updateNetworkActivityIndicatorForWebView:webView];
    self.title = [self parseTitleFromWebView:webView];;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateNetworkActivityIndicatorForWebView:webView];

    [self prepareWebViewPopupLinks:webView];

    self.title = [self parseTitleFromWebView:webView];
}

- (void)updateNetworkActivityIndicatorForWebView:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:webView.isLoading];
}


#pragma mark User Interaction

- (void)tappedCancel {
    if ([self.delegate respondsToSelector:@selector(threeDSecureViewControllerDidFinish:)]) {
        [self.delegate threeDSecureViewControllerDidFinish:self];
    }
}


#pragma mark Web View Inspection

- (NSString *)parseTitleFromWebView:(UIWebView *)webView {
    return [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}


#pragma mark Web View Popup Links

- (void)prepareWebViewPopupLinks:(UIWebView *)webView {
    NSString *js = [NSString stringWithFormat:@"var as = document.getElementsByTagName('a');\
                    for (var i = 0; i < as.length; i++) {\
                    if (as[i]['target'] === '_new') { as[i]['href'] = '%@+' + as[i]['href']; } \
                    }", BTThreeDSecureAuthenticationViewControllerPopupDummyURLScheme];
    [webView stringByEvaluatingJavaScriptFromString:js];
}

- (BOOL)detectPopupLinkForURL:(NSURL *)URL {
    NSString *schemePrefix = [[URL.scheme componentsSeparatedByString:@"+"] firstObject];
    return [schemePrefix isEqualToString:BTThreeDSecureAuthenticationViewControllerPopupDummyURLScheme];
}

- (BOOL)detectPopupCloseLinkForURL:(NSURL *)URL {
    return [URL.scheme isEqualToString:@"close"];
}

- (NSURL *)extractPopupLinkURL:(NSURL *)URL {
    NSURLComponents *c = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    c.scheme = [[URL.scheme componentsSeparatedByString:@"+"] lastObject];

    return c.URL;
}

- (void)openPopupWithURL:(NSURL *)URL {
    BTThreeDSecurePopupWebViewViewController *popup = [[BTThreeDSecurePopupWebViewViewController alloc] initWithURL:URL];
    UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:popup];

    popup.delegate = self;

    [self presentViewController:navigationViewController animated:YES completion:nil];
}


#pragma mark BTThreeDSecurePopupWebViewViewControllerDelegate

- (void)popupWebViewViewControllerDidFinish:(BTThreeDSecurePopupWebViewViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
