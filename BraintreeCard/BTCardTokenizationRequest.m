#import "BTCardTokenizationRequest.h"

@implementation BTCardTokenizationRequest

- (instancetype)initWithCard:(BTCard *)card {
    if (!card) {
        return nil;
    }
    if (self = [super init]) {
        _card = card;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

@end
