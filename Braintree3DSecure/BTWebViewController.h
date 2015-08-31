#import <UIKit/UIKit.h>
#import <BraintreeCore/BTNullability.h>

BT_ASSUME_NONNULL_BEGIN

@interface BTWebViewController : UIViewController

#pragma mark - Designated initializers

- (nonnull instancetype)initWithRequest:(nonnull NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

#pragma mark - Undesignated initializers (do not use)

- (BT_NULLABLE instancetype)initWithCoder:(NSCoder *)decoder __attribute__((unavailable("Please use initWithRequest: instead.")));
- (instancetype)initWithNibName:(BT_NULLABLE NSString *)nibName bundle:(BT_NULLABLE NSBundle *)nibBundle __attribute__((unavailable("Please use initWithRequest: instead.")));

#pragma mark Override Points for Subclasses

- (BOOL)webView:(nonnull UIWebView *)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType __attribute__((objc_requires_super));
- (void)webViewDidStartLoad:(nonnull UIWebView *)webView __attribute__((objc_requires_super));
- (void)webViewDidFinishLoad:(nonnull UIWebView *)webView __attribute__((objc_requires_super));
- (void)webView:(nonnull UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error;

@end

BT_ASSUME_NONNULL_END

