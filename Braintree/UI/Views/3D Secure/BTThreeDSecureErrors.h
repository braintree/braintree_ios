@import Foundation;

extern NSString *BTThreeDSecureErrorDomain;

typedef NS_ENUM(NSInteger, BTThreeDSecureErrorCode) {
    BTThreeDSecureUnknownErrorCode = 0,
    BTThreeDSecureFailedLookupErrorCode,
    BTThreeDSecureFailedAuthenticationErrorCode,
};

extern NSString *BTThreeDSecureInfoKey;
