#import "BTTokenization.h"

@interface BTTokenization ()
@property (nonatomic, copy, readwrite) NSString *nonce;
@property (nonatomic, copy, readwrite) NSString *localizedDescription;
@end

@implementation BTTokenization

- (instancetype)initWithNonce:(NSString *)nonce localizedDescription:(NSString *)description {
    if (!nonce) return nil;
    
    if (self = [super init]) {
        self.nonce = nonce;
        self.localizedDescription = description;
    }
    return self;
}

- (NSString *)type {
    return @"Unknown";
}

@end
