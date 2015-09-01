#import <UIKit/UIKit.h>

@interface BTWebViewController : UIViewController

- (nonnull instancetype)initWithRequest:(nonnull NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

#pragma mark Override Points for Subclasses

- (BOOL)webView:(nonnull UIWebView *)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType __attribute__((objc_requires_super));
- (void)webViewDidStartLoad:(nonnull UIWebView *)webView __attribute__((objc_requires_super));
- (void)webViewDidFinishLoad:(nonnull UIWebView *)webView __attribute__((objc_requires_super));
- (void)webView:(nonnull UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error;

@end
