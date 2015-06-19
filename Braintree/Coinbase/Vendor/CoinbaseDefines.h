#import <Foundation/Foundation.h>

/// If the API request is successful, `response` will be either a NSDictionary or NSArray, and `error` will be nil.
/// Otherwise, `error` will be non-nil.
typedef void (^CoinbaseCompletionBlock)(id response, NSError *error);

/// NSError domain for Coinbase errors.
extern NSString *const CoinbaseErrorDomain;

/// NSError codes for Coinbase errors.
typedef NS_ENUM(NSInteger, CoinbaseErrorCode) {
    CoinbaseOAuthError,
    CoinbaseServerErrorUnknown,
    CoinbaseServerErrorWithMessage
};

