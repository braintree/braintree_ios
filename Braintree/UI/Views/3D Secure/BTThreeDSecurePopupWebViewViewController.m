#import "BTThreeDSecurePopupWebViewViewController.h"

NSString *BTThreeDSecurePopupWebViewViewControllerCloseURLScheme = @"com.braintreepayments.popup.close";

@interface BTThreeDSecurePopupWebViewViewController () <UIWebViewDelegate>
@property (nonatomic, copy) NSURLRequest *URLRequest;
@end

@implementation BTThreeDSecurePopupWebViewViewController

- (instancetype)initWithURL:(NSURL *)URL {
    self = [self init];
    if (self) {
        self.URLRequest = [NSURLRequest requestWithURL:URL];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(informDelegateDidFinish)];

    [self loadRequest:self.URLRequest];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self prepareWebViewPopupCloseLinks:webView];

    [super webViewDidFinishLoad:webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:BTThreeDSecurePopupWebViewViewControllerCloseURLScheme]) {
        [self informDelegateDidFinish];
        return NO;
    }

    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
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

#pragma mark Delegate Informers

- (void)informDelegateDidFinish {
    if ([self.delegate respondsToSelector:@selector(popupWebViewViewControllerDidFinish:)]) {
        [self.delegate popupWebViewViewControllerDidFinish:self];
    }
}

@end
