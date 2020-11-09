#if __has_include(<Braintree/BraintreeCard.h>)
#import <Braintree/BTCardRequest.h>
#else
#import <BraintreeCard/BTCardRequest.h>
#endif

@implementation BTCardRequest

- (instancetype)initWithCard:(BTCard *)card {
    if (!card) {
        return nil;
    }
    if (self = [super init]) {
        _card = card;
    }
    return self;
}

@end
