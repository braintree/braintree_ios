#import <Foundation/Foundation.h>
#import "BTCacheDateValidator_Internal.h"

#ifndef MockBTCacheDateValidator_h
#define MockBTCacheDateValidator_h
@interface MockBTCacheDateValidator : BTCacheDateValidator
@property (nonatomic) BOOL isCacheInvalid;

-(BOOL) isCacheInvalid:(NSCachedURLResponse *)cachedConfigurationResponse;
@end
#endif
