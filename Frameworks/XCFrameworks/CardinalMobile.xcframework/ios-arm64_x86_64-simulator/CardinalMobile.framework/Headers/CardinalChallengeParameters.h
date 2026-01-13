//
//  CardinalChallengeParameters.h
//  CardinalMobile
//
//  Created by Salvador Ramirez on 3/22/24.
//  Copyright © 2024 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CardinalChallengeParameters : NSObject
@property (nonnull, strong) NSString* threeDSServerTransactionId;
@property (nonnull, strong) NSString* acsTransactionId;
@property (nonnull, strong) NSString* acsReferenceNumber;
@property (nonnull, strong) NSString* acsSignedContent;
@property (nonnull, strong) NSString* threeDSRequestorAppURL;
@property (nonnull, strong) NSString* sdkTransactionId;
@property (nonnull, strong) NSString* transactionId;
- (NSString *) getThreeDSServerTransactionId;
- (NSString *) getACSTransactionId;
- (NSString *) getACSReferenceNumber;
- (NSString *) getACSSignedContent;
- (NSString *) getThreeDSRequestorAppURL;
- (NSString *) getSDKTransactionId;
- (NSString *) getTransactionId;
@end

NS_ASSUME_NONNULL_END
