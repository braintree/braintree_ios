/**
 Copyright © 2018 Visa. All rights reserved.
 */

#import <UIKit/UIKit.h>
@import WebKit;

/**
 VisaCheckoutPlugin is used to configure Visa Checkout for hybrid environments. 
 VisaCheckoutPlugin conforms to the WKScriptMessageHandler protocol and
 will act as a message handler for your instance of WKWebView.
 */
@interface VisaCheckoutPlugin : NSObject <WKScriptMessageHandler>

/// :nodoc:
- (instancetype _Nonnull)init NS_UNAVAILABLE;

/**
 Singleton instance of VisaCheckoutPlugin that is used to configure 
 Visa Checkout for hybrid environments. Use this instance when adding
 message handlers to your instance of WKWebView.
 */
@property (class, nonatomic, readonly) VisaCheckoutPlugin * _Nonnull main;

/**
 Provide an instance of UIViewController that will be used to present Visa Checkout
 modally. When the Visa Checkout button is clicked by the user, VisaCheckoutPlugin
 will use this view controller to call `present(_:animated:completion:)`.
 
 This property is required to launch Visa Checkout. The UIViewController instance 
 must be in your view hierarchy and must not already have a presentingViewController 
 set because any additional calls to `present(_:animated:completion:)` will be
 ignored by UIKit.
 
 Typically, you will set this value to the view controller that contains your 
 webView.
 */
@property (nonatomic, weak) UIViewController * _Nullable presentingViewController;

/**
 You can use this method as a one line integration for configuring Visa Checkout
 for hybrid environments. You can call this method passing an instance of your WKWebView
 contentController for the webview that will eventually render the Visa Checkout button. Also pass in an instance
 of UIViewController that is able to be used in a call to present(_:animated:completion:).

 @param contentController an instance of the webView's userContentController, usually
 accessed in this manner: myWkWebView.configuration.userContentController
 
 @param viewController an instance of UIViewController that will be used to present Visa Checkout
 modally. When the Visa Checkout button is clicked by the user, VisaCheckoutPlugin
 will use this view controller to call `present(_:animated:completion:)`.
 */
+ (void)configure:(WKUserContentController *_Nonnull)contentController
   viewController:(UIViewController *_Nonnull)viewController;

/**
    This method should be called within the merchant's WKUIDelegate method,
    `webView:createWebViewWithConfiguration:forNavigationAction: windowFeatures:`. Calling this
    will allow Visa Checkout to be properly initialized. This is required for VisaCheckoutPlugin support.

    @param request a request object for the webview to be created

    @param configuration a configuration object for the webview to be created
*/
+ (WKWebView *_Nullable)finishSetupWithRequest:(NSURLRequest *_Nonnull)request andConfiguration:(WKWebViewConfiguration *_Nonnull)configuration;


/**
   While `VisaCheckoutPlugin` is a singleton, calling this method helps remove related objects when they are no longer needed
 */
+ (void)cleanup;

@end
