//
//  PayPalTouch.h
//
//  Version 2.11.1-bt1
//
//  Copyright (c) 2014, PayPal
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayPalConfiguration.h"

typedef NS_ENUM(NSUInteger, PayPalTouchResultType) {
  PayPalTouchResultTypeError,
  PayPalTouchResultTypeCancel,
  PayPalTouchResultTypeSuccess,
};

/// This class represents the result of the App Switch.
@interface PayPalTouchResult : NSObject
/// resultType can be success, cancel or some sort of an error
@property (nonatomic, readonly, assign) PayPalTouchResultType resultType;
/// When App Switch is successful the authorization dictionary
/// containing information that your server will need to process the payment.
@property (nonatomic, readonly, copy) NSDictionary *authorization;
/// This dictionary is always present when resultType is PayPalTouchResultTypeError.
/// This dictionary is sometimes present when resultType is PayPalTouchResultTypeCancel.
/// The "message" and "debug_id" are for developer integaration to help analyze a problem,
/// and never for user display.
@property (nonatomic, readonly, copy) NSDictionary *error;

@end

@class PayPalTouch;

/// This class checks availability of auth via app switch, handles the app switch
/// and provides methods for use to handle results of auth via app switch.
///
/// This class is offered for integrations that initiate app switch without
/// the PayPal UI, and thus must obtain and handle results directly.
/// For more typical drop-in handling
@interface PayPalTouch : NSObject

#pragma mark - Direct PayPal Touch Auth

/// Whether the authorizer is available on the device
/// and the current app is set up to receive the callback.
///
/// @return YES if the authorization method is available
+ (BOOL)canAppSwitchForUrlScheme:(NSString*) scheme;

/// Obtain future payments authorization via app switch.
///
/// Available for backward compatibility.
/// Same functionality can be achieved using `authorizeScopeValues:configuration:` using required scopes.
///
/// @param configuration The configuration to be used for the app switch
/// @return YES if app switch was successful
+ (BOOL)authorizeFuturePayments:(PayPalConfiguration *)configuration __attribute__((deprecated("Please use authorizeScopeValues:configuration: instead")));

/// @param scopeValues Set of requested scope-values. Each scope-value is defined in PayPalOAuthScopes.h.
/// @param configuration The configuration to be used for the app switch
/// @return YES if app switch was successful
/// @note Given limitations in the Wallet app, the only scopes allowed are: https://uri.../futurepayments, email, address, phone, openid
+ (BOOL)authorizeScopeValues:(NSSet *)scopeValues configuration:(PayPalConfiguration *)configuration;

/// Process a URL request.
///
/// This method is exposed for integrations that initiate app switch without
/// the PayPal UI, and thus must obtain and handle results directly.
///
/// @param  url   The url to handle
/// @return PayPalTouchResult containing result of the App Switch.
///
+ (PayPalTouchResult *)parseAppSwitchURL:(NSURL *)url;

#pragma mark - Custom URL handling

/// Whether the URL and source application are recognized and valid
/// for PayPal Touch.
///
/// This method is exposed for integrations that initiate app switch without
/// the PayPal UI, and thus must obtain and handle results directly.
/// For more typical drop-in handling
///
/// @param  url The URL of the app switch request
/// @param  sourceApplication The bundle ID of the source application
///
/// @return Whether the application that made the request is valid.
+ (BOOL)canHandleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
