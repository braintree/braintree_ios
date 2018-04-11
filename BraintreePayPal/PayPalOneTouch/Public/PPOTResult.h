//
//  PPOTResult.h
//
//  Copyright © 2015 PayPal, Inc. All rights reserved.
//

/**
 PayPal One Touch request targets.
 */
typedef NS_ENUM(NSInteger, PPOTRequestTarget) {
    /// No app switch will occur
    PPOTRequestTargetNone,

    /// App switch to/from browser
    PPOTRequestTargetBrowser,

    /// App switch to/from PayPal Consumer App
    PPOTRequestTargetOnDeviceApplication,

    /// Response url was invalid; can't confirm source app's identity
    PPOTRequestTargetUnknown,
};

#define kPayPalOneTouchErrorDomain @"com.paypal.onetouch.error"

/**
 Error codes associated with PayPal One Touch.
 */
typedef NS_ENUM(NSInteger, PPOTErrorCode) {
    /// Unknown error
    PPOTErrorCodeUnknown = -1000,

    /// Parsing failed
    PPOTErrorCodeParsingFailed = -1001,

    /// App target not found
    PPOTErrorCodeNoTargetAppFound = -1002,

    /// Failed to open URL
    PPOTErrorCodeOpenURLFailed = -1003,

    /// Persisted data fetch failed
    PPOTErrorCodePersistedDataFetchFailed = -1004,
};

/**
 PayPal One Touch result types.
 */
typedef NS_ENUM(NSInteger, PPOTResultType) {
    /// Error
    PPOTResultTypeError,

    /// Cancel
    PPOTResultTypeCancel,

    /// Success
    PPOTResultTypeSuccess,
};

/**
 The result of parsing the One Touch return URL
*/
@interface PPOTResult : NSObject

/**
 The status of the app switch
*/
@property (nonatomic, readonly, assign) PPOTResultType type;

/**
 When One Touch is successful, the response dictionary containing information that your server will need to process.
*/
@property (nullable, nonatomic, readonly, copy) NSDictionary *response;

/**
 When One Touch encounters an error, it is reported here. Otherwise this property will be `nil`.
*/
@property (nullable, nonatomic, readonly, copy) NSError *error;

/**
 The target app that is now switching back.
*/
@property (nonatomic, readonly, assign) PPOTRequestTarget target;

@end

