//
//  PayPalOneTouchCore.h
//
//  Version 3.2.2
//
//  Copyright (c) 2015 PayPal Inc. All rights reserved.
//

/// PayPalOneTouchRequestTargetNone - no app-switch will occur
/// PayPalOneTouchRequestTargetBrowser - app-switch to/from browser
/// PayPalOneTouchRequestTargetOnDeviceApplication - app-switch to/from PayPal Consumer App
/// PayPalOneTouchRequestTargetUnknown - response url was invalid; can't confirm source app's identity
typedef NS_ENUM(NSUInteger, PayPalOneTouchRequestTarget) {
  PayPalOneTouchRequestTargetNone,
  PayPalOneTouchRequestTargetBrowser,
  PayPalOneTouchRequestTargetOnDeviceApplication,
  PayPalOneTouchRequestTargetUnknown,
};

#define kPayPalOneTouchErrorDomain @"com.paypal.onetouch.error"
typedef NS_ENUM(NSUInteger, PayPalOneTouchErrorCode) {
  PayPalOneTouchErrorCodeUnknown = -1000,
  PayPalOneTouchErrorCodeParsingFailed = -1001,
  PayPalOneTouchErrorCodeNoTargetAppFound = -1002,
  PayPalOneTouchErrorCodeOpenURLFailed = -1003,
};

typedef NS_ENUM(NSUInteger, PayPalOneTouchResultType) {
  PayPalOneTouchResultTypeError,
  PayPalOneTouchResultTypeCancel,
  PayPalOneTouchResultTypeSuccess,
};

/// The result of parsing the app-switch-back-to-OTC url
@interface PayPalOneTouchCoreResult : NSObject

/// Success, cancel or some sort of error
@property (nonatomic, readonly, assign) PayPalOneTouchResultType type;
/// When OneTouch is successful, the response dictionary
/// containing information that your server will need to process.
@property (nonatomic, readonly, copy) NSDictionary *response;
/// When OneTouch encounters an error, it is reported here. Otherwise this property will be `nil`.
@property (nonatomic, readonly, copy) NSError *error;
/// The target app which is now app-switching back to us.
@property (nonatomic, readonly, assign) PayPalOneTouchRequestTarget target;

@end

