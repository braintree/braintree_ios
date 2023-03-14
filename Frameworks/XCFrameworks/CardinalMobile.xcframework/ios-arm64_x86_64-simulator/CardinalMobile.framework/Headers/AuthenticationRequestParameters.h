//
//  AuthenticationRequestParameters.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The AuthenticationRequestParameters class holds transaction data that the App passes to the 3DS Server for creating the AReq.
 */
@interface AuthenticationRequestParameters : NSObject

- (id _Nonnull ) initWithSDKTransactionId: (NSString *_Nonnull) sdkTransactionId
                               deviceData: (NSString *_Nonnull) deviceData
                    sdkEphemeralPublicKey: (NSString *_Nonnull) sdkEphemeralPublicKey
                                 sdkAppID: (NSString *_Nonnull) sdkAppID
                       sdkReferenceNumber: (NSString *_Nonnull) sdkReferenceNumber
                           messageVersion: (NSString *_Nonnull) messageVersion;

/**
 * @property sdkTransactionID SDK Transaction ID.
 */
@property (nonnull, nonatomic, strong, readonly) NSString* sdkTransactionID;

/**
 * @property deviceData Device data collected by the SDK.
 */
@property (nullable, nonatomic, strong, readonly) NSString* deviceData;

/**
 * @property sdkEphemeralPublicKey SDK Ephemeral Public Key (Qc).
 */
@property (nonnull, nonatomic, strong, readonly) NSString* sdkEphemeralPublicKey;

/**
 * @property sdkAppID SDK App ID.
 */
@property (nonnull, nonatomic, strong, readonly) NSString* sdkAppID;

/**
 * @property sdkReferenceNumber SDK Reference Number.
 */
@property (nonnull, nonatomic, strong, readonly) NSString* sdkReferenceNumber;

/**
 * @property messageVersion Protocol version that is supported by the SDK and used for the transaction.
 */
@property (nonnull, nonatomic, strong, readonly) NSString* messageVersion;

/**
 * The getDeviceData method returns the encrypted device data as a string.
 * @return NSString
 */
- (NSString *_Nullable) getDeviceData;

/**
 * The getSDKTransactionID method returns the SDK Transaction ID.
 * @return NSString
 */
- (NSString *_Nonnull) getSDKTransactionID;

/**
 * The getSDKAppID method returns the SDK App ID.
 * @return NSString
 */
- (NSString *_Nonnull) getSDKAppID;

/**
 * The getSDKReferenceNumber method returns the SDK Reference Number.
 * @return NSString
 */
- (NSString *_Nonnull) getSDKReferenceNumber;

/**
 * The getSDKEphemeralPublicKey method returns the SDK Ephemeral Public Key.
 * @return NSString
 */
- (NSString *_Nonnull) getSDKEphemeralPublicKey;

/**
 * The getMessageVersion method returns the protocol version that is used for the transaction.
 * @return NSString
 */
- (NSString *_Nonnull) getMessageVersion;

+ (instancetype _Nonnull )new NS_UNAVAILABLE;
- (instancetype _Nonnull )init NS_UNAVAILABLE;

@end
