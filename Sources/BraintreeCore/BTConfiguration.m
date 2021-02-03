#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTConfiguration.h>
#else
#import <BraintreeCore/BTConfiguration.h>
#endif

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

- (NSString *)environment {
    return [self.json[@"environment"] asString];
}

@end
