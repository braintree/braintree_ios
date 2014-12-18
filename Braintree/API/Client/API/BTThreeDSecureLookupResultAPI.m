#import "BTThreeDSecureLookupResultAPI.h"

@implementation BTThreeDSecureLookupResultAPI

+ (Class)resourceModelClass {
    return [BTThreeDSecureLookupResult class];
}

+ (NSDictionary *)APIFormat {
    return @{
             @"md": BTAPIResourceValueTypeString(@selector(setMD:)),
             @"pareq": BTAPIResourceValueTypeOptional(BTAPIResourceValueTypeString(@selector(setPAReq:))),
             @"acsUrl": BTAPIResourceValueTypeOptional(BTAPIResourceValueTypeURL(@selector(setAcsURL:))),
             @"termUrl": BTAPIResourceValueTypeOptional(BTAPIResourceValueTypeURL(@selector(setTermURL:))),
             };
}

@end
