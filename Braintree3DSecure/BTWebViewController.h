#import <UIKit/UIKit.h>
#import <BraintreeCore/BTNullability.h>

BT_ASSUME_NONNULL_BEGIN

@interface BTWebViewController : UIViewController

#pragma mark - Designated initializers

- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

#pragma mark - Undesignated initializers (do not use)

- (BT_NULLABLE instancetype)initWithCoder:(NSCoder *)decoder __attribute__((unavailable("Please use initWithRequest: instead.")));
- (instancetype)initWithNibName:(BT_NULLABLE NSString *)nibName bundle:(BT_NULLABLE NSBundle *)nibBundle __attribute__((unavailable("Please use initWithRequest: instead.")));

#pragma mark Override Points for Subclasses

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType __attribute__((objc_requires_super));
- (void)webViewDidStartLoad:(UIWebView *)webView __attribute__((objc_requires_super));
- (void)webViewDidFinishLoad:(UIWebView *)webView __attribute__((objc_requires_super));
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end

BT_ASSUME_NONNULL_END
