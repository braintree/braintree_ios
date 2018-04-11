#import <Foundation/Foundation.h>

/**
 An error domain for 3D Secure errors.

 @see BTThreeDSecure
*/
extern NSString * const BTThreeDSecureErrorDomain;

/**
 The key for 3D Secure info in the `NSError` `userInfo` dictionary.
 */
extern NSString * const BTThreeDSecureInfoKey;

/**
 The key for 3D Secure validation errors in the `NSError` `userInfo` dictionary.
 */
extern NSString * const BTThreeDSecureValidationErrorsKey;

/**
 Error codes that describe errors that occur during 3D Secure.
*/
typedef NS_ENUM(NSInteger, BTThreeDSecureErrorType){
    /// Unknown error
    BTThreeDSecureErrorTypeUnknown = 0,
    
    /// 3D Secure failed during the backend card lookup phase; please retry
    BTThreeDSecureErrorTypeFailedLookup,
    
    /// 3D Secure failed during the user-facing authentication phase; please retry
    BTThreeDSecureErrorTypeFailedAuthentication,
    
    /// Braintree SDK is integrated incorrectly
    BTThreeDSecureErrorTypeIntegration,
};
