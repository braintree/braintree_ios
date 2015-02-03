#ifndef BT_THREE_D_SECURE_BETA_WARNING
#define BT_THREE_D_SECURE_BETA_WARNING
#pragma message "⚠️ Braintree's 3D Secure API for iOS is currently in beta and subject to change in the near future"
#endif

@import Foundation;

/// An error domain for 3D Secure errors
///
/// @see BTThreeDSecure
extern NSString *BTThreeDSecureErrorDomain;

 /// Error codes that describe errors that occur during 3D Secure
typedef NS_ENUM(NSInteger, BTThreeDSecureErrorCode){
    /// An unknown error related to 3D Secure occured.
    BTThreeDSecureUnknownErrorCode = 0,
    /// 3D Secure failed during the backend card lookup phase; please retry.
    BTThreeDSecureFailedLookupErrorCode,
    /// 3D Secure failed during the user-facing authentication phase; please retry.
    BTThreeDSecureFailedAuthenticationErrorCode,
};
