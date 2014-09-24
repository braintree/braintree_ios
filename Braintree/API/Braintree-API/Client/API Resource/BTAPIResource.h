@import Foundation;

#import "BTAPIResourceErrors.h"

@protocol BTAPIResourceValueType;

id<BTAPIResourceValueType> BTAPIResourceValueTypeString(SEL setter);
id<BTAPIResourceValueType> BTAPIResourceValueTypeStringSet(SEL setter);
id<BTAPIResourceValueType> BTAPIResourceValueTypeAPIResource(SEL setter, Class BTAPIResourceClass);
id<BTAPIResourceValueType> BTAPIResourceValueTypeOptional(id<BTAPIResourceValueType> APIResourceValueType);

@interface BTAPIResource : NSObject

+ (id)modelWithAPIDictionary:(NSDictionary *)APIDictionary error:(NSError *__autoreleasing *)error;

+ (NSDictionary *)APIDictionaryWithModel:(id)resource;


#pragma mark Abstract Methods

+ (Class)resourceModelClass;

+ (NSDictionary *)APIFormat;

@end
