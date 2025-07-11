/**
 Copyright © 2018 Visa. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VisaProfile.h"

extern NSString * _Nonnull const kVisaCheckoutResultResult;
extern NSString * _Nonnull const kVisaCheckoutResultCallID;
extern NSString * _Nonnull const kVisaCheckoutResultCardBrand;
extern NSString * _Nonnull const kVisaCheckoutResultCountryCode;
extern NSString * _Nonnull const kVisaCheckoutResultEncryptionKey;
extern NSString * _Nonnull const kVisaCheckoutResultEncryptedPaymentData;
extern NSString * _Nonnull const kVisaCheckoutResultLastFourDigits;
extern NSString * _Nonnull const kVisaCheckoutResultPartialShippingAddress;
extern NSString * _Nonnull const kVisaCheckoutResultPartialPaymentInstrument;
extern NSString * _Nonnull const kVisaCheckoutResultPaymentType;
extern NSString * _Nonnull const kVisaCheckoutResultPaymentMethodType;
extern NSString * _Nonnull const kVisaCheckoutResultPostalCode;
extern NSString * _Nonnull const kVisaCheckoutResultStatusCode;
extern NSString * _Nonnull const kVisaCheckoutResultStatusName;
extern NSString * _Nonnull const kVisaCheckoutResultType;
extern NSString * _Nonnull const kVisaCheckoutResultPaymentSuccess;
extern NSString * _Nonnull const kVisaCheckoutResultPaymentCancel;
extern NSString * _Nonnull const kVisaCheckoutResultPaymentError;
extern NSString * _Nonnull const kVisaCheckoutResultNetworkError;

/**
 The result code indicating the status of a completed Visa Checkout
 transaction. This is the code found in the `statusCode` of the
 `VisaCheckoutResult` class.
 */
typedef NS_ENUM(NSInteger, VisaCheckoutResultStatus) {
    /** Your call to attempt a manual checkout was rejected because the user
     interface is already being shown to the user.
     */
    VisaCheckoutResultStatusDuplicateCheckoutAttempt,
    
    /**
     An internal error occurred. This is unexpected behavior and should be
     reported to a Visa Checkout team member.
     */
    VisaCheckoutResultStatusInternalError,
    
    /**
     You have not configured `VisaCheckoutSDK`. You need to make sure you
     call `[VisaCheckoutSDK configure]`.
     */
    VisaCheckoutResultStatusNotConfigured,
    
    /**
     This is a successful checkout attempt. If `statusCode` is
     `VisaCheckoutResultStatusSuccess`, then all of the other payment information is assumed
     to be valid.
     */
    VisaCheckoutResultStatusSuccess,

    /**
     The user cancelled the checkout attempt by closing down the user interface.
     */
    VisaCheckoutResultStatusUserCancelled,
    
    /**
     The device has become disconnected from the network and checkout is disabled.
     You can handle this accordingly or simply wait until the device is reconnected.
     */
    VisaCheckoutResultStatusNetworkError,
    
    /**
     Reserved for future use
     */
    VisaCheckoutResultDefault,
} NS_SWIFT_NAME(CheckoutResultStatus);

/**
 The `CheckoutResult` class is the object that is returned when a Visa Checkout
 launch has occurred and finished. This class will contain information
 related to the user's payment if successful. If the checkout attempt was
 unsuccessful, it will contain an error code in `statusCode`.
 
 For future use, if any more values are added to VisaCheckoutResult, they can be
 accessed using subscripting.
 e.g. if a key called `info` is added to the result, its value can be accessed as
 result[@"info"], where result is an instance of VisaCheckoutResult.
 
 To view the textual representation of VisaCheckoutResult, the `description` property
 can be used.
 */
NS_SWIFT_NAME(CheckoutResult)
@interface VisaCheckoutResult : NSObject

/// :nodoc:
- (instancetype _Nonnull )init __unavailable;

/**
 An internal identifier provided by the Visa Checkout SDK.
 Use this value as the value for the `PurchaseInfo.referenceCallId`
 property if you need to make modifications to a successful checkout
 transaction.
 */
@property (nonatomic, readonly, copy) NSString *_Nullable callId;

/**
 The brand of the credit card the user has chosen to use for this purchase.
 */
@property (nonatomic) VisaCardBrand cardBrand;

/**
 The type of card the user has chosen, such as CREDIT or DEBIT.
 */
@property (nonatomic) NSString *_Nullable cardType;

/**
 The country associated with this user.
 */
@property (nonatomic) VisaCountry country DEPRECATED_MSG_ATTRIBUTE("Use countryCode instead.");

/**
 The country associated with this user.
 This is only populated if `statusCode` is of type `VisaCheckoutResultStatusSuccess`.
 */
@property (nonatomic) NSString *_Nonnull countryCode;

/**
 The encrypted key that is used to decrypt the `encryptedPaymentData`.
 This is only populated if `statusCode` is of type `VisaCheckoutResultStatusSuccess`.
 */
@property (nonatomic, readonly, copy) NSString *_Nullable encryptedKey;

/**
 The encrypted payment data containing the card information.
 This data needs to be decrypted using the `encryptedKey`.
 This is only populated if `statusCode` is of type `VisaCheckoutResultStatusSuccess`.
 */
@property (nonatomic, readonly, copy) NSString *_Nullable encryptedPaymentData;

/**
 The last four digits of the credit card the user has chosen to use for this purchase.
 */
@property (nonatomic, readonly, copy) NSString *_Nullable lastFourDigits;

/**
 The payment method type, set to either TOKEN or PAN.
 */
@property (nonatomic, readonly, copy) NSString *_Nullable paymentMethodType;

/**
 The postal code associated with this user.
 This is only populated if `statusCode` is of type `VisaCheckoutResultStatusSuccess`.
 */
@property (nonatomic, readonly, copy) NSString *_Nullable postalCode;

/// The status of this checkout attempt.
@property (nonatomic, readonly) VisaCheckoutResultStatus statusCode;

/// A value representing the status of this checkout attempt (e.g. `kVisaCheckoutResultPaymentSuccess`)
@property (nonatomic, readonly) NSString *_Nonnull statusName;

/// :nodoc:
- (id _Nullable )objectForKeyedSubscript:(NSString *_Nonnull)key;

@end

/// :nodoc:
typedef void(^VisaCheckoutResultHandler)(VisaCheckoutResult *_Nonnull result);
