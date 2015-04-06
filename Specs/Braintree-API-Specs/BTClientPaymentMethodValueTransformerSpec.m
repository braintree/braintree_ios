#import "BTClientPaymentMethodValueTransformer.h"
#import "BTPayPalPaymentMethod.h"
#import "BTCoinbasePaymentMethod.h"

SpecBegin(BTClientPaymentMethodValueTransformer)

__block NSMutableDictionary *responseDictionary;
__block NSValueTransformer *valueTransformer;

beforeEach(^{
    responseDictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                         @"nonce": @"a-nonce-value",
                                                                         @"details": @{@"email": @"email@foo.bar"}}];
    valueTransformer = [NSValueTransformer valueTransformerForName:NSStringFromClass([BTClientPaymentMethodValueTransformer class])];
});

context(@"PayPal", ^{

    beforeEach(^{
        responseDictionary[@"type"] = @"PayPalAccount";
    });

    it(@"returns a PayPal payment method with a nonce even if description is null", ^{
        responseDictionary[@"description"] = [NSNull null];
        //[responseDictionary removeObjectForKey:@"description"];
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
});

context(@"Coinbase", ^{
    beforeEach(^{
        responseDictionary[@"type"] = @"CoinbaseAccount";
    });

    it(@"returns a payment method with a nonce, an email and a description matching the email", ^{
        BTCoinbasePaymentMethod *paymentMethod = [valueTransformer transformedValue:responseDictionary];
        expect(paymentMethod).to.beKindOf([BTCoinbasePaymentMethod class]);
        expect(paymentMethod.nonce).to.equal(@"a-nonce-value");
        expect(paymentMethod.email).to.equal(@"email@foo.bar");
        expect(paymentMethod.description).to.equal(paymentMethod.email);
    });

    it(@"returns a payment method with nil description and email if email is null", ^{
        responseDictionary[@"details"] = @{@"email": [NSNull null]};
        BTCoinbasePaymentMethod *paymentMethod = [valueTransformer transformedValue:responseDictionary];
        expect(paymentMethod.description).to.beNil();
        expect(paymentMethod.email).to.beNil();
    });

    it(@"ignores the description field", ^{
        responseDictionary[@"description"] = @"Some description";
        BTCoinbasePaymentMethod *paymentMethod = [valueTransformer transformedValue:responseDictionary];
        expect(paymentMethod.description).to.equal(@"email@foo.bar");
    });
});

SpecEnd
