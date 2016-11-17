@import PassKit;

#import "BTAPIResponseParser.h"

@interface BTAPIResponseParser ()
@property (nonatomic, strong) NSDictionary *apiDictionary;
@end

@implementation BTAPIResponseParser

+ (instancetype)parserWithDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initWithDictionary:dictionary];
}

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    self = [super init];
    if (self) {
        self.apiDictionary = dictionary;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [BTAPIResponseParser parserWithDictionary:[self.apiDictionary copyWithZone:zone]];
}

#pragma mark -

- (NSString *)stringForKey:(NSString *)key {
    NSString *value = self.apiDictionary[key];
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

- (NSArray *)arrayForKey:(NSString *)key {
    NSArray *value = self.apiDictionary[key];
    return [value isKindOfClass:[NSArray class]] ? value : nil;
}

- (NSSet *)setForKey:(NSString *)key {
    NSArray *value = self.apiDictionary[key];
    return [value isKindOfClass:[NSArray class]] ? [NSSet setWithArray:value] : nil;
}

- (NSURL *)URLForKey:(NSString *)key {
    NSString *urlString = [self stringForKey:key];
    if (!urlString) {
        return nil;
    }

    return [NSURL URLWithString:urlString];
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    NSDictionary *value = self.apiDictionary[key];
    return [value isKindOfClass:[NSDictionary class]] ? value : nil;
}

- (BTAPIResponseParser *)responseParserForKey:(NSString *)key {
    return [BTAPIResponseParser parserWithDictionary:[self dictionaryForKey:key]];
}


#pragma mark - Transformed Values

- (id)objectForKey:(NSString *)key withValueTransformer:(id<BTValueTransforming>)valueTransformer {
    id originalValue = self.apiDictionary[key];
    return [valueTransformer transformedValue:originalValue];
}

- (NSArray *)arrayForKey:(NSString *)key withValueTransformer:(id<BTValueTransforming>)valueTransformer {
    NSArray *originalValue = [self arrayForKey:key];
    NSMutableArray *value = [NSMutableArray arrayWithCapacity:originalValue.count];
    for (id obj in originalValue) {
        id transformedObj = [valueTransformer transformedValue:obj];
        if (transformedObj != [NSNull null]) {
            [value addObject:transformedObj];
        }
    }
    return [value copy];
}

- (NSInteger)integerForKey:(NSString *)key withValueTransformer:(id<BTValueTransforming>)valueTransformer {
    id originalValue = self.apiDictionary[key];
    id transformedValue = [valueTransformer transformedValue:originalValue];
    return [transformedValue isKindOfClass:[NSNumber class]] ? [transformedValue integerValue] : 0;
}

- (BOOL)boolForKey:(NSString *)key withValueTransformer:(id<BTValueTransforming>)valueTransformer {
    id originalValue = self.apiDictionary[key];
    id transformedValue = [valueTransformer transformedValue:originalValue];
    return [transformedValue isKindOfClass:[NSNumber class]] ? [transformedValue boolValue] : NO;
}


#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSDictionary *apiDictionary = [aDecoder decodeObjectForKey:@"apiDictionary"];
    return [self initWithDictionary:apiDictionary];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.apiDictionary forKey:@"apiDictionary"];
}

#pragma mark NSObject Protocol

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[BTAPIResponseParser class]]) {
        return (self == object) || [self.apiDictionary isEqual:[object apiDictionary]];
    } else {
        return [super isEqual:object];
    }
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<BTAPIResponseParser: %p %@>", self, [self.apiDictionary debugDescription]];
}

@end


