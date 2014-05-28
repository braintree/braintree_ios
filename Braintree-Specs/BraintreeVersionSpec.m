#import "Braintree.h"

SpecBegin(BraintreeVersion)

it(@"returns the current version", ^{
    expect([Braintree libraryVersion]).to.beKindOf([NSString class]);
});

SpecEnd
