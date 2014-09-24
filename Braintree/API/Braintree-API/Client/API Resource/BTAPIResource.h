@import Foundation;

extern NSString *const BTAPIResourceErrorDomain;

typedef NS_ENUM(NSInteger, BTAPIResourceErrorCode) {
    BTAPIResourceErrorUnknown,
    BTAPIResourceErrorResourceSpecificationInvalid,
    BTAPIResourceErrorResourceDictionaryMissingKey,
    BTAPIResourceErrorResourceDictionaryInvalid,
};

@protocol BTAPIResourceValueType;

id<BTAPIResourceValueType> BTAPIResourceValueTypeString(SEL modelStringSetter);
id<BTAPIResourceValueType> BTAPIResourceValueTypeStringSet(SEL modelStringSetSetter);
id<BTAPIResourceValueType> BTAPIResourceValueTypeAPIResource(Class BTAPIResourceClass);
id<BTAPIResourceValueType> BTAPIResourceValueTypeOptional(id<BTAPIResourceValueType> APIResourceValueType);

@interface BTAPIResource : NSObject

+ (id)resourceWithAPIDictionary:(NSDictionary *)APIDictionary error:(NSError *__autoreleasing *)error;

+ (NSDictionary *)APIDictionaryWithResource:(id)resource;


#pragma mark Methods to Override

+ (Class)resourceModelClass;

+ (NSDictionary *)APIFormat;

@end

@protocol BTAPIResourceValueType

- (BOOL)isValidValue:(id)value;

- (void)setValue:(id)value onModel:(id)model;

@end