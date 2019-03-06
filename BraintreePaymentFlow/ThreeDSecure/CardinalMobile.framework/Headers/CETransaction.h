//
//  CCTransaction.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transaction.h"

@interface CETransaction : NSObject<Transaction>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
