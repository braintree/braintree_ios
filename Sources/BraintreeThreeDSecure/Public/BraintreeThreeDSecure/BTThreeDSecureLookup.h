#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The result of a 3DS lookup.

 Contains liability shift and challenge information.
 */
@interface BTThreeDSecureLookup : NSObject

/**
 The "PAReq" or "Payment Authentication Request" is the encoded request message used to initiate authentication.
 */
@property (nonatomic, nullable, readonly, copy) NSString *PAReq;

/**
 The unique 3DS identifier assigned by Braintree to track the 3DS call as it progresses.
 */
@property (nonatomic, nullable, readonly, copy) NSString *MD;

/**
 The URL which the customer will be redirected to for a 3DS Interface. In 3DS 1, there will always be an acsURL surfaced even if there isn't a password challenge. In 3DS 2, the presense of an acsURL indicates there is a challenge as it would otherwise frictionlessly complete without an acsURL.
 */
@property (nonatomic, nullable, readonly) NSURL *acsURL;

/**
 The termURL is the fully qualified URL that the customer will be redirected to once the authentication completes.
 */
@property (nonatomic, nullable, readonly) NSURL *termURL;

/**
 The full version string of the 3DS lookup result.
 */
@property (nonatomic, nullable, readonly, copy) NSString *threeDSecureVersion;

/**
 Indicates a 3DS 2 lookup result.
 */
@property (nonatomic, readonly) BOOL isThreeDSecureVersion2;

/**
 This a secondary unique 3DS identifier assigned by Braintree to track the 3DS call as it progresses.
 */
@property (nonatomic, nullable, readonly, copy) NSString *transactionID;

/**
 Indicates that a 3DS challenge is required.
 */
@property (nonatomic, readonly) BOOL requiresUserAuthentication;

@end

NS_ASSUME_NONNULL_END
