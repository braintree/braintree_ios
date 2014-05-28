#import "BTMutablePayPalAccount.h"

SpecBegin(BTMutablePayPalAccount)

describe(@"setNonce", ^{
    it(@"stores a PayPal account nonce", ^{
        BTMutablePayPalAccount *payPalAccount = [BTMutablePayPalAccount new];
        payPalAccount.nonce = @"a-nonce";
        expect(payPalAccount.nonce).to.equal(@"a-nonce");
    });
});


describe(@"debug descripton", ^{
    it(@"returns a useful representation of the account", ^{
        BTMutablePayPalAccount *payPalAccount = [[BTMutablePayPalAccount alloc] init];
        payPalAccount.description = @"A PayPal account";
        payPalAccount.nonce = [[NSUUID UUID] UUIDString];
        payPalAccount.email = @"user@example.com";


        expect([payPalAccount debugDescription]).to.contain(payPalAccount.nonce);
        expect([payPalAccount debugDescription]).to.contain(payPalAccount.email);
        expect([payPalAccount debugDescription]).to.contain(payPalAccount.description);
    });
});

SpecEnd
