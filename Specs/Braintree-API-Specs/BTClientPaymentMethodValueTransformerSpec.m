#import "BTClientPaymentMethodValueTransformer.h"
#import "BTPayPalPaymentMethod.h"

SpecBegin(BTClientPaymentMethodValueTransformer)

__block NSMutableDictionary *responseDictionary;
__block NSValueTransformer *valueTransformer;

beforeEach(^{
    responseDictionary = [NSMutableDictionary dictionaryWithDictionary:@{ @"type": @"PayPalAccount",
                                                                          @"nonce": @"a-nonce-value",
                                                                          @"details": @{@"email": @"email@foo.bar"}}];
    valueTransformer = [NSValueTransformer valueTransformerForName:NSStringFromClass([BTClientPaymentMethodValueTransformer class])];
});

it(@"returns a PayPal payment method with nil description if description is null", ^{
    responseDictionary[@"description"] = [NSNull null];
    BTPayPalPaymentMethod *paymentMethod = [valueTransformer transformedValue:responseDictionary];
    expect(paymentMethod).to.beKindOf([BTPayPalPaymentMethod class]);
    expect(paymentMethod.nonce).to.equal(@"a-nonce-value");
});

it(@"returns a PayPal payment method with nil description if description is null", ^{
    responseDictionary[@"description"] = [NSNull null];
    BTPayPalPaymentMethod *paymentMethod = [valueTransformer transformedValue:responseDictionary];
    expect(paymentMethod.description).to.beNil();
});

it(@"returns a PayPal payment method with nil description if description is 'PayPal'", ^{
    responseDictionary[@"description"] = @"PayPal";
    BTPayPalPaymentMethod *paymentMethod = [valueTransformer transformedValue:responseDictionary];
    expect(paymentMethod.description).to.beNil();
});

it(@"returns a PayPal payment method with the description if description is not 'PayPal' and non-nil", ^{
    responseDictionary[@"description"] = @"foo";
    BTPayPalPaymentMethod *paymentMethod = [valueTransformer transformedValue:responseDictionary];
    expect(paymentMethod.description).equal(@"foo");
});

SpecEnd
