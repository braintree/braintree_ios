//
//  PayPalOneTouchCore.h
//
//  Version 3.2.2
//
//  Copyright (c) 2015 PayPal Inc. All rights reserved.
//

// Required Frameworks for the library. Additionaly make sure to set OTHER_LDFLAGS = -ObjC
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <Foundation/Foundation.h>
#import "PayPalOneTouchCoreResult.h"

/// Completion block for receiving the result of performing a request
typedef void (^PayPalOneTouchCompletionBlock)(PayPalOneTouchCoreResult *result);

@interface PayPalOneTouchCore : NSObject

/// Check if the application is configured correctly to handle responses for OneTouch flow.
///
/// @param callbackURLScheme The URL scheme which the app has registered for OneTouch responses.
/// @return YES iff the application is correctly configured.
+ (BOOL)doesApplicationSupportOneTouchCallbackURLScheme:(NSString *)callbackURLScheme;

/// Check whether the PayPal Wallet app is installed on this device (iOS <=8)
/// Universal links are used in iOS >=9 so the check is not performed
///
/// @return YES if the wallet app is installed
+ (BOOL)isWalletAppInstalled;

/// Check whether the URL and source application are recognized and valid for OneTouch.
///
/// Usually called as a result of the UIApplication delegate's
/// `- (BOOL)application:openURL:sourceApplication:annotation:` method,
/// to determine if the URL is intended for the OneTouchCore library.
///
/// (To then actually process the URL, call `+ (void)parseOneTouchURL:completionBlock`.)
///
/// @param url The URL of the app switch request
/// @param sourceApplication The bundle ID of the source application
///
/// @return YES iff the URL and sending app are both valid.
+ (BOOL)canParseURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/// Process a URL response.
///
/// @param url The URL to process
/// @return PayPalOneTouchResult containing result of the OneTouch.
+ (void)parseResponseURL:(NSURL *)url completionBlock:(PayPalOneTouchCompletionBlock)completionBlock;

/// Once a user has consented to future payments, when the user subsequently initiates a PayPal payment
/// from their device to be completed by your server, PayPal uses a Client Metadata ID to verify that the
/// payment is originating from a valid, user-consented device+application.
///
/// This helps reduce fraud and decrease declines.
///
/// This method MUST be called prior to initiating a pre-consented payment (a "future payment") from a mobile device.
/// Pass the result to your server, to include in the payment request sent to PayPal.
/// Do not otherwise cache or store this value.
///
/// @return clientMetadataID Your server will send this to PayPal in a 'PayPal-Client-Metadata-Id' header.
+ (NSString *)clientMetadataID;

/// Once a user has consented to future payments, when the user subsequently initiates a PayPal payment
/// from their device to be completed by your server, PayPal uses a Client Metadata ID to verify that the
/// payment is originating from a valid, user-consented device+application.
///
/// This helps reduce fraud and decrease declines.
///
/// This method MUST be called prior to initiating a pre-consented payment (a "future payment") from a mobile device.
/// Pass the result to your server, to include in the payment request sent to PayPal.
/// Do not otherwise cache or store this value.
///
/// @param a pairingId (ex: EC-Token) to associate with this clientMetadataID must be 10-32 chars long or null
/// @return clientMetadataID Your server will send this to PayPal in a 'PayPal-Client-Metadata-Id' header.
+ (NSString *)clientMetadataID:(NSString *)pairingId;

/// For payment processing, the client's server will first create a payment on the PayPal server.
/// Creating that payment requires, among many other things, a `redirect_urls` object containing two strings:
/// `return_url` and `cancel_url`.
///
/// These are the URLs used to return control from the browser to the app containing the OneTouchCore library.
///
/// The client will obtain these URLs by calling this method.
///
/// @param callbackURLScheme The URL scheme which the app has registered for OneTouch responses.
/// @param returnURL A NSString pointer to receive the `return_url`.
/// @param cancelURL A NSString pointer to receive the `cancel_url`.
///
/// @note Both return values will be nil if [PayPalOneTouchCore doesApplicationSupportOneTouchCallbackURLScheme:callbackURLScheme] is not true.
+ (void)redirectURLsForCallbackURLScheme:(NSString *)callbackURLScheme withReturnURL:(NSString **)returnURL withCancelURL:(NSString **)cancelURL;

/// @return The version of the SDK library in use. Version numbering follows http://semver.org/.
/// @note Please be sure to include this library version in tech support requests.
+ (NSString *)libraryVersion;

@end
