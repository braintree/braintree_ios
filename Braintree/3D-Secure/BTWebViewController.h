@import UIKit;

@interface BTWebViewController : UIViewController

- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

#pragma mark Override Points for Subclasses

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType __attribute__((objc_requires_super));
- (void)webViewDidStartLoad:(UIWebView *)webView __attribute__((objc_requires_super));
- (void)webViewDidFinishLoad:(UIWebView *)webView __attribute__((objc_requires_super));
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end
