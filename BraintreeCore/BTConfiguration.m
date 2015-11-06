#import "BTConfiguration.h"

@implementation BTConfiguration

- (instancetype)init {
    @throw [[NSException alloc] initWithName:@"Invalid initializer" reason:@"Use designated initializer" userInfo:nil];
}

- (instancetype)initWithJSON:(BTJSON *)json {
    if (self = [super init]) {
        _json = json;
    }
    return self;
}
@end
