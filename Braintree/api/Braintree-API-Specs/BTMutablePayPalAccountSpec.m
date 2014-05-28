#import "BTMutablePayPalPaymentMethod.h"

SpecBegin(BTMutablePayPalPaymentMethod)

describe(@"setNonce", ^{
    it(@"stores a PayPal account nonce", ^{
        BTMutablePayPalPaymentMethod *payPalPaymentMethod = [BTMutablePayPalPaymentMethod new];
        payPalPaymentMethod.nonce = @"a-nonce";
        expect(payPalPaymentMethod.nonce).to.equal(@"a-nonce");
    });
});


describe(@"debug descripton", ^{
    it(@"returns a useful representation of the account", ^{
        BTMutablePayPalPaymentMethod *payPalPaymentMethod = [[BTMutablePayPalPaymentMethod alloc] init];
        payPalPaymentMethod.description = @"A PayPal account";
        payPalPaymentMethod.nonce = [[NSUUID UUID] UUIDString];
        payPalPaymentMethod.email = @"user@example.com";


        expect([payPalPaymentMethod debugDescription]).to.contain(payPalPaymentMethod.nonce);
        expect([payPalPaymentMethod debugDescription]).to.contain(payPalPaymentMethod.email);
        expect([payPalPaymentMethod debugDescription]).to.contain(payPalPaymentMethod.description);
    });
});

SpecEnd
