//
//  CertificateInfoConfiguration.h
//  CardinalMobile
//
//  Created by Praveen Rao on 11/21/22.
//  Copyright © 2022 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardinalError.h"
#import "CardinalSessionConfiguration.h"


NS_ASSUME_NONNULL_BEGIN

@interface CertificateInfoConfiguration : NSObject
@property (nonatomic,strong) CardinalSessionConfiguration *config;
- (id) initWithName: (CardinalSessionConfiguration *) config;
-(void)callCertificateInfoAPIWithbaseURL:(NSURL*)baseURL sdkTransactionID:(NSString *)sdkTransactionID merchantJWT: (NSString *)merchantJWTString onComplete:(void(^)(BOOL success, CardinalError * _Nullable error))onCompletion;
-(BOOL) getCardBrandFromLocal: (NSString *) cardBrand;
-(NSString *) getSDKReferenceNumber;
-(NSNumber *) getKeyChainVersion;
@end

NS_ASSUME_NONNULL_END

