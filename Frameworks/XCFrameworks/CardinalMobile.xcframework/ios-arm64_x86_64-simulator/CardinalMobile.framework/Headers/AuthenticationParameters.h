//
//  AuthenticationParameters.h
//  CardinalMobile
//
//  Created by Praveen Rao on 12/15/22.
//  Copyright © 2022 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardinalSessionConfigPrivate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AuthenticationParameters : NSObject
/**
 * The AuthenticationParameters class holds transaction data.
 */

- (id) initWithSDKTransactionId: (NSString *) sdkTransactionId deviceData: (NSString *) deviceData sdkEphemeralPublicKey: (NSString *) sdkEphemeralPublicKey sdkAppID: (NSString *) sdkAppID sdkReferenceNumber: (NSString *) sdkReferenceNumber messageVersion: (NSString *) messageVersion sdkUiType: (CardinalUiTypeArray *) sdkUiType sdkRenderType: (NSString *) sdkRenderType sdkMaxTimeout: (NSUInteger) sdkMaxTimeout;

/**
 * The getAuthJsonString method returns the Authentication JSON string.
 * @return NSString
 */
-(NSString*) getAuthJsonString;

@property (nonnull, nonatomic, strong) NSString* sdkTransactionID;
@property (nullable, nonatomic, strong) NSString* deviceData;
@property (nonnull, nonatomic, strong) NSString* sdkEphemeralPublicKey;
@property (nonnull, nonatomic, strong) NSString* sdkAppID;
@property (nonnull, nonatomic, strong) NSString* sdkReferenceNumber;
@property (nonnull, nonatomic, strong) NSString* messageVersion;
@property (nonnull, nonatomic, strong) CardinalUiTypeArray* sdkUiType;
@property (nonnull, nonatomic, strong) NSString* sdkRenderType;
@property (nonnull, nonatomic, strong) NSString* sdkType;
@property (nonnull, nonatomic, strong) NSString* sdkMaxTimeout;
@end

NS_ASSUME_NONNULL_END
