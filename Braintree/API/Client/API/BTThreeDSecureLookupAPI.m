#import "BTThreeDSecureLookupAPI.h"

@implementation BTThreeDSecureLookupAPI

+ (Class)resourceModelClass {
    return [BTThreeDSecureLookup class];
}

+ (NSDictionary *)APIFormat {
    return @{
             @"nonce": BTAPIResourceValueTypeString(@selector(setNonce:)),
             @"pareq": BTAPIResourceValueTypeOptional(BTAPIResourceValueTypeString(@selector(setPAReq:))),
             @"acsUrl": BTAPIResourceValueTypeOptional(BTAPIResourceValueTypeURL(@selector(setAcsURL:))),
             @"termUrl": BTAPIResourceValueTypeOptional(BTAPIResourceValueTypeURL(@selector(setTermURL:))),
             };
}

@end
