#import <Foundation/Foundation.h>
@class BTJSON;

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information about the 3D Secure status of a payment method
 */
@interface BTThreeDSecureInfo : NSObject

/**
 Create a `BTThreeDSecureInfo` object from JSON.
 */
- (instancetype)initWithJSON:(BTJSON *)json;

/**
 Unique transaction identifier assigned by the Access Control Server (ACS) to identify a single transaction.
 */
@property (nonatomic, readonly, nullable) NSString *acsTransactionID;

/**
 On authentication, the transaction status result identifier.
 */
@property (nonatomic, readonly, nullable) NSString *authenticationTransactionStatus;

/**
 On authentication, provides additional information as to why the transaction status has the specific value.
 */
@property (nonatomic, readonly, nullable) NSString *authenticationTransactionStatusReason;

/**
 Cardholder authentication verification value or "CAVV" is the main encrypted message issuers and card networks use to verify authentication has occured. Mastercard uses an "AVV" message which will also be returned in the cavv parameter.
 */
@property (nonatomic, readonly, nullable) NSString *cavv;

/**
 Directory Server Transaction ID is an ID used by the card brand's 3DS directory server.
 */
@property (nonatomic, readonly, nullable) NSString *dsTransactionID;

/**
 The ecommerce indicator flag indicates the outcome of the 3DS authentication. Possible values are 00, 01, and 02 for Mastercard 05, 06, and 07 for all other cardbrands.
 */
@property (nonatomic, readonly, nullable) NSString *eciFlag;

/**
 Indicates whether a card is enrolled in a 3D Secure program or not. Possible values:
    `Y` = Yes
    `N` = No
    `U` = Unavailable
    `B` = Bypass
    `E` = RequestFailure
 */
@property (nonatomic, readonly, nullable) NSString *enrolled;

/**
 If the 3D Secure liability shift has occurred.
 */
@property (nonatomic, readonly, assign) BOOL liabilityShifted;

/**
 If the 3D Secure liability shift is possible.
 */
@property (nonatomic, readonly, assign) BOOL liabilityShiftPossible;

/**
 On lookup, the transaction status result identifier.
 */
@property (nonatomic, readonly, nullable) NSString *lookupTransactionStatus;

/**
 On lookup, provides additional information as to why the transaction status has the specific value.
 */
@property (nonatomic, readonly, nullable) NSString *lookupTransactionStatusReason;

/**
 The Payer Authentication Response (PARes) Status, a transaction status result identifier. Possible Values:
 * Y – Successful Authentication
 * N – Failed Authentication
 * U – Unable to Complete Authentication
 * A – Successful Stand-In Attempts Transaction
 */
@property (nonatomic, readonly, nullable) NSString *paresStatus;

/**
 The 3D Secure status value.
 */
@property (nonatomic, readonly, nullable) NSString *status;

/**
 Unique identifier assigned to the 3D Secure authentication performed for this transaction.
*/
@property (nonatomic, readonly, nullable) NSString *threeDSecureAuthenticationID;

/**
 Unique transaction identifier assigned by the 3DS Server to identify a single transaction.
 */
@property (nonatomic, readonly, nullable) NSString *threeDSecureServerTransactionID;

/**
 The 3DS version used in the authentication, example "1.0.2" or "2.1.0".
 */
@property (nonatomic, readonly, nullable) NSString *threeDSecureVersion;

/**
 Indicates if the 3D Secure lookup was performed.
 */
@property (nonatomic, readonly, assign) BOOL wasVerified;

/**
 Transaction identifier resulting from 3D Secure authentication. Uniquely identifies the transaction and sometimes required in the authorization message. This field will no longer be used in 3DS 2 authentications.
 */
@property (nonatomic, readonly, nullable) NSString *xid;

@end

NS_ASSUME_NONNULL_END
