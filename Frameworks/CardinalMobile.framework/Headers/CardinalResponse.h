//
//  CardinalResponse.h
//  CardinalMobileSDK
//
//  Copyright © 2018 CardinalCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// For further documentation: https://cardinaldocs.atlassian.net/wiki/spaces/CC/pages/98315/Response+Objects

/*!
 * @typedef CardinalResponseActionCode
 * @brief List of resulting state of the transaction.
 * @constant CardinalResponseActionCodeSuccess The transaction resulted in success for the payment type used.
 * @constant CardinalResponseActionCodeNoAction The API calls to Centinel API were completed and there is no further actionable items to complete.
 * @constant CardinalResponseActionCodeFailure The transaction resulted in an error.
 * @constant CardinalResponseActionCodeError A service level error was encountered.
 * @constant CardinalResponseActionCodeCancel The transaction was cancelled by the user.
 */
typedef NS_ENUM(NSUInteger, CardinalResponseActionCode) {
    CardinalResponseActionCodeSuccess,
    CardinalResponseActionCodeNoAction,
    CardinalResponseActionCodeFailure,
    CardinalResponseActionCodeError,
    CardinalResponseActionCodeCancel
};

// REVISIT: Turn these string values into enums for better type/value checking (wjf, 2018-02)
@interface CardinalPaymentExtendedData : NSObject

/*!
 * @property enrolled Enrolled
 * @brief Status of Authentication eligibility.
 * Possible Values:
 * Y = Yes- Bank is participating in 3D Secure protocol and will return the ACSUrl
 * N = No - Bank is not participating in 3D Secure protocol
 * U = Unavailable - The DS or ACS is not available for authentication at the time of the request
 * B = Bypass- Merchant authentication rule is triggered to bypass authentication in this use case
 */
@property (nonatomic, readonly) NSString *enrolled;

/*!
 * @property paResStatus PA Res Status
 * @brief Transaction status result identifier.
 * Possible Values:
 * Y – Successful Authentication
 * N – Failed Authentication
 * U – Unable to Complete Authentication
 * A – Successful Attempts Transaction
 */
@property (nonatomic, readonly) NSString *paResStatus;

/*!
 * @property signatureVerification Signature Verification
 * @brief Transaction Signature status identifier.
 * Possible Values:
 * Y - Indicates that the signature of the PARes has been validated successfully and the message contents can be trusted.
 * N - Indicates that the PARes could not be validated. This result could be for a variety of reasons; tampering, certificate expiration, etc., and the result should not be trusted.
 */
@property (nonatomic, readonly) NSString *signatureVerification;

/*!
 * @property cavv CAVV
 * @brief Cardholder Authentication Verification Value (CAVV)
 */
@property (nonatomic, readonly) NSString *cavv;

/*!
 * @property eciFlag ECIFlag
 * @brief Electronic Commerce Indicator (ECI). The ECI value is part of the 2 data elements that indicate the transaction was processed electronically.
 */
@property (nonatomic, readonly) NSString *eciFlag;

/*!
 * @property xid XId
 * @brief Transaction identifier resulting from authentication processing.
 */
@property (nonatomic, readonly) NSString *xid;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

// TODO: Turn these string values into enums for better type/value checking (wjf, 2018-02)
@interface CardinalPayment : NSObject

/*!
 * @property type Type
 * @brief The payment type of this transaction.
 * Possible Values:
 * CCA - Cardinal Consumer Authentication
 * Paypal
 * Wallet
 * VisaCheckout
 * ApplePay
 * DiscoverWallet
 */
@property (nonatomic, readonly) NSString *type;

/*!
 * @property processorTransactionId Processor Transaction Id
 * @brief The Transaction Identifier returned back from the Processor.
 * Possible Values:
 * CCA - Cardinal Consumer Authentication
 * Paypal
 * Wallet
 * VisaCheckout
 * ApplePay
 * DiscoverWallet
 */
@property (nonatomic, readonly) NSString *processorTransactionId;

/*!
 * @property extendedData Extended Data
 * @brief This will contain an extension object that corresponds to the Payment Type of this transaction.
 */
@property (nullable, nonatomic, readonly) CardinalPaymentExtendedData *extendedData;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

/*!
 * @interface CardinalResponse Cardinal Response
 * @brief Response from the Cardinal after Validation.
 */
@interface CardinalResponse : NSObject

/*!
 * @property isValidated isValidated
 * @brief This value represents whether transaction was successfully or not.
 */
@property (nonatomic, readonly) BOOL isValidated;

/*!
 * @property payment Payment
 * @brief CardinalPayment object.
 * Check CardinalPayment object for detail information.
 */
@property (nullable, nonatomic, readonly) CardinalPayment *payment;

/*!
 * @property actionCode Action Code
 * @brief The resulting state of the transaction.
 * Check CardinalResponseActionCode enum for detail.
 */
@property (nonatomic, readonly) CardinalResponseActionCode actionCode;

/*!
 * @property errorNumber Error Number
 * @brief Application error number. A non-zero value represents the error encountered while attempting the process the message request.
 */
@property (nonatomic, readonly) NSInteger errorNumber;

/*!
 * @property errorDescription Error Description
 * @brief Application error description for the associated error number.
 */
@property (nonatomic, readonly) NSString *errorDescription;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
