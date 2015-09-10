#import "BTTokenization.h"
#import "BTTokenizationParser.h"

@interface BTTokenizationParser ()

/// Dictionary of JSON parsing blocks keyed by types as strings. The blocks have the following type:
///
/// `id <BTTokenized>(^)(NSDictionary *json)`
@property (nonatomic, strong) NSMutableDictionary *JSONParsingBlocks;

@end

@implementation BTTokenizationParser

+ (instancetype)sharedParser {
    static BTTokenizationParser *sharedParser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedParser = [[BTTokenizationParser alloc] init];
    });
    return sharedParser;
}

- (NSMutableDictionary *)JSONParsingBlocks {
    if (!_JSONParsingBlocks) {
        _JSONParsingBlocks = [NSMutableDictionary dictionary];
    }
    return _JSONParsingBlocks;
}

- (BOOL)isTypeAvailable:(NSString *)type {
    return self.JSONParsingBlocks[type] != nil;
}

- (NSArray *)allTypes {
    return self.JSONParsingBlocks.allKeys;
}

- (void)registerType:(NSString *)type withParsingBlock:(id <BTTokenized>(^)(BTJSON *))jsonParsingBlock {
    if (jsonParsingBlock) {
        self.JSONParsingBlocks[type] = [jsonParsingBlock copy];
    }
}

- (id<BTTokenized>)parseJSON:(BTJSON *)json withParsingBlockForType:(NSString *)type {
    id <BTTokenized>(^block)(BTJSON *) = self.JSONParsingBlocks[type];
    if (!json) {
        return nil;
    }
    if (block) {
        return block(json);
    }
    // Unregistered types should fall back to parsing basic nonce and description from JSON
    if (!json[@"nonce"].isString) return nil;
    return [[BTTokenization alloc] initWithNonce:json[@"nonce"].asString localizedDescription:json[@"description"].asString];
}

@end
