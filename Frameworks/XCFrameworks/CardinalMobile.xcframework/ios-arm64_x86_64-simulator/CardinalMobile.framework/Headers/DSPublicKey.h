//
//  DSPublicKey.h
//  CardinalEMVCoSDK
//
//  Created by Sudeep Tuladhar on 6/7/18.
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAImageUrl.h"

typedef enum{
    PublicKeyAlgorithmRSA,
    PublicKeyAlgorithmEC
} PublicKeyAlgorithm;

typedef enum{
    PublicKeyTypeKey,
    PublicKeyTypeCertificate
} PublicKeyType;

NS_ASSUME_NONNULL_BEGIN

@interface DSPublicKey : NSObject

@property (nonatomic, strong) const NSString* dsId;
@property (nonatomic, strong) NSString* publicKey;
@property (nonatomic, strong) NSString* dsCert;
@property (nonatomic, strong) NSString* threeDSVersion;
@property (nonatomic, strong) CCAImageUrl* imageUrl;

@property (nonatomic) PublicKeyAlgorithm algorithm;
@property (nonatomic) PublicKeyType keyType;

- (id) initWithDict: (NSDictionary *) dict isV3: (BOOL) isV3;

@end
NS_ASSUME_NONNULL_END
