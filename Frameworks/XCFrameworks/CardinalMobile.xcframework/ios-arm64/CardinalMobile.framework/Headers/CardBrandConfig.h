//
//  CardBrandConfig.h
//  CardinalMobile
//
//  Created by Salvador Ramirez on 3/6/23.
//  Copyright © 2023 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSPublicKey.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardBrandConfig : NSObject

@property (nonnull, strong) NSDictionary* certificateDictionary;
@property (nonnull, strong) NSString* cardBrand;

-(id) initWithCardBrand: (NSString *) cardBrand withCertificates: (NSString *) certificates;
- (DSPublicKey *) getPublicKeyForCardBrand: (NSString *) cardBrand;
- (NSString *) getRootCertificate;
- (NSString *) getKID: (NSString *) cardBrand;
- (NSString *) getAlgorithm: (NSString *) cardBrand;

@end

NS_ASSUME_NONNULL_END
