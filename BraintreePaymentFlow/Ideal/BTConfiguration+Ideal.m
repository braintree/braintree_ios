#import "BTConfiguration+Ideal.h"

@implementation BTConfiguration (Ideal)

- (BOOL)isIdealEnabled {
    return (self.routeId != nil);
}

- (NSString *)routeId {
    return [self.json[@"ideal"][@"routeId"] asString];
}

- (NSString *)idealAssetsUrl {
    return [self.json[@"ideal"][@"assetsUrl"] asString];
}

@end
