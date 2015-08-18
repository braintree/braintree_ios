//
// BTCoinbaseDefines.h
//
// Vendored from the official Coinbase iOS SDK version 3.0:
// https://github.com/coinbase/coinbase-ios-sdk
//

#import <Foundation/Foundation.h>

/// If the API request is successful, `response` will be either a NSDictionary or NSArray, and `error` will be nil.
/// Otherwise, `error` will be non-nil.
typedef void (^BTCoinbaseCompletionBlock)(id response, NSError *error);

/// NSError domain for Coinbase errors.
extern NSString *const BTCoinbaseErrorDomain;

/// NSError codes for Coinbase errors.
typedef NS_ENUM(NSInteger, BTCoinbaseErrorCode) {
    BTCoinbaseOAuthError,
    BTCoinbaseServerErrorUnknown,
    BTCoinbaseServerErrorWithMessage
};

