#import <Foundation/Foundation.h>

@protocol BTValueTransforming <NSObject>
- (id)transformedValue:(id)value;
@end

@interface BTAPIResponseParser : NSObject <NSCopying, NSCoding>

+ (instancetype)parserWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

#pragma mark - Accessors with Specified Types

- (NSString *)stringForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (NSSet *)setForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key;
- (NSURL *)URLForKey:(NSString *)key;

#pragma mark - Accessors for Nested Resources

- (BTAPIResponseParser *)responseParserForKey:(NSString *)key;

#pragma mark - Accessors with Transformed Values

- (id)objectForKey:(NSString *)key withValueTransformer:(id<BTValueTransforming>)valueTransformer;
- (NSArray *)arrayForKey:(NSString *)key withValueTransformer:(id<BTValueTransforming>)valueTransformer;
- (NSInteger)integerForKey:(NSString *)key withValueTransformer:(id<BTValueTransforming>)valueTransformer;
- (BOOL)boolForKey:(NSString *)key withValueTransformer:(id<BTValueTransforming>)valueTransformer;

@end
