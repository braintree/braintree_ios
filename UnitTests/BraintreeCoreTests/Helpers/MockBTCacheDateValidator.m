#import <Foundation/Foundation.h>
#import "BTCacheDateValidator_Internal.h"
#import "MockBTCacheDateValidator.h"

@implementation MockBTCacheDateValidator : BTCacheDateValidator

-(BOOL)isCacheInvalid:(NSCachedURLResponse *)cachedConfigurationResponse {
    return _isCacheInvalid;
}

@end
