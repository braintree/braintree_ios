#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTConfiguration+ThreeDSecure.h>
#else
#import <BraintreeThreeDSecure/BTConfiguration+ThreeDSecure.h>
#endif

@implementation BTConfiguration (ThreeDSecure)

- (NSString *)cardinalAuthenticationJWT {
    return [self.json[@"threeDSecure"][@"cardinalAuthenticationJWT"] asString];
}

@end
