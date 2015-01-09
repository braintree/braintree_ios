#import "BTThreeDSecurePopupWebViewViewController.h"

NSString *BTThreeDSecurePopupWebViewViewControllerCloseURLScheme = @"close";

@interface BTThreeDSecurePopupWebViewViewController () <UIWebViewDelegate>
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation BTThreeDSecurePopupWebViewViewController

- (instancetype)initWithURL:(NSURL *)URL {
    self = [self init];
    if (self) {
        self.URL = URL;
        self.webView = [[UIWebView alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(informDelegateDidFinish)];

    self.view.backgroundColor = [UIColor whiteColor];

    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.delegate = self;
    self.webView.accessibilityIdentifier = @"Popup Web View";
    [self.webView loadRequest:self.initialURLRequest];
    [self.view addSubview:self.webView];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"webView": self.webView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"webView": self.webView}]];
}

- (NSURLRequest *)initialURLRequest {
    return [NSURLRequest requestWithURL:self.URL];
}


#pragma mark Delegate Informers

- (void)informDelegateDidFinish {
    if ([self.delegate respondsToSelector:@selector(popupWebViewViewControllerDidFinish:)]) {
        [self.delegate popupWebViewViewControllerDidFinish:self];
    }
}


#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self prepareWebViewPopupCloseLinks:webView];
}

- (BOOL)webView:(__unused UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(__unused UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:BTThreeDSecurePopupWebViewViewControllerCloseURLScheme]) {
        [self informDelegateDidFinish];
        return NO;
    }

    return YES;
}

- (void)prepareWebViewPopupCloseLinks:(UIWebView *)webView {
    NSString *js = [NSString stringWithFormat:@"var as = document.getElementsByTagName('a');\
                    for (var i = 0; i < as.length; i++) {\
                        if (as[i]['href'] === 'javascript:window.close();') { as[i]['href'] = '%@://'; } \
                    }\
                    var forms = document.getElementsByTagName('form');\
                    for (var i = 0; i < forms.length; i++) {\
                        if (forms[i]['action'].indexOf('close_window.htm') > -1) { forms[i]['action'] = '%@://'; } \
                    }", BTThreeDSecurePopupWebViewViewControllerCloseURLScheme, BTThreeDSecurePopupWebViewViewControllerCloseURLScheme];
    [webView stringByEvaluatingJavaScriptFromString:js];
}

@end
