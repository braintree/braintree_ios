#import "BTWebViewController.h"
#import "BTThreeDSecurePopupWebViewViewController.h"

static NSString *BTWebViewControllerPopupDummyURLScheme = @"com.braintreepayments.popup.open";

@interface BTWebViewController () <UIWebViewDelegate, BTThreeDSecurePopupWebViewViewControllerDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation BTWebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.webView = [[UIWebView alloc] init];
        self.webView.accessibilityIdentifier = @"Web View";
    }
    return self;
}

- (void)loadView {
    self.view = self.webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateNetworkActivityIndicatorForWebView:self.webView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    [self updateNetworkActivityIndicatorForWebView:self.webView];
}

- (void)loadRequest:(NSURLRequest *)request {
    [self.webView loadRequest:request];
}

- (void)updateNetworkActivityIndicatorForWebView:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:webView.isLoading];
}


#pragma mark UIWebViewDelegate

- (BOOL)webView:(__unused UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked && [self detectPopupLinkForURL:request.URL]) {
        [self openPopupWithURL:[self extractPopupLinkURL:request.URL]];
        return NO;
    }

    return YES;
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

- (void)webView:(__unused UIWebView *)webView didFailLoadWithError:(__unused NSError *)error {
    // TODO: Retry/cancel
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
                    }", BTWebViewControllerPopupDummyURLScheme];
    [webView stringByEvaluatingJavaScriptFromString:js];
}

- (BOOL)detectPopupLinkForURL:(NSURL *)URL {
    NSString *schemePrefix = [[URL.scheme componentsSeparatedByString:@"+"] firstObject];
    return [schemePrefix isEqualToString:BTWebViewControllerPopupDummyURLScheme];
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
