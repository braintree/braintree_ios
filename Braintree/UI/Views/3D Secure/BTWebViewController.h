@import UIKit;

@interface BTWebViewController : UIViewController

- (void)loadRequest:(NSURLRequest *)request;

#pragma mark Override Points for Subclasses

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType __attribute__((objc_requires_super));
- (void)webViewDidStartLoad:(UIWebView *)webView __attribute__((objc_requires_super));
- (void)webViewDidFinishLoad:(UIWebView *)webView __attribute__((objc_requires_super));
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error __attribute__((objc_requires_super));

@end
