//
//  ChallengeResponse.h
//  CardinalMobile
//
//  Created by Praveen Rao on 4/4/23.
//  Copyright © 2023 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChallengeResponse : NSObject
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, strong) NSNumber* ErrorNumber;
@property (nonatomic, strong) NSString* ErrorDescription;
@property (nonatomic, strong) NSString* Type;
@property (nonatomic, strong) NSString* Payload;
- (instancetype)initWithJSONData:(NSData *)JSONData;
@end

NS_ASSUME_NONNULL_END
