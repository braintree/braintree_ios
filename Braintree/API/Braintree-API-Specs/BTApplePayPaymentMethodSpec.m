#import "BTApplePayPaymentMethod.h"
#import "BTMutableApplePayPaymentMethod.h"

SpecBegin(BTApplePayPaymentMethod)

__block BTApplePayPaymentMethod *immutable;

beforeEach(^{
    immutable = [[BTApplePayPaymentMethod alloc] init];
});

describe(@"mutableCopy", ^{
    it(@"returns a BTMutableApplyPayPaymentMethod", ^{
        id copy = [immutable mutableCopy];
        expect(copy).to.beKindOf([BTMutableApplePayPaymentMethod class]);
    });
});

describe(@"copy", ^{
    it(@"returns a BTApplyPayPaymentMethod", ^{
        id copy = [immutable copy];
        expect(copy).to.beKindOf([BTApplePayPaymentMethod class]);
    });
});

SpecEnd

SpecBegin(BTMutableApplePayPaymentMethod)

__block BTMutableApplePayPaymentMethod *mutable;

beforeEach(^{
    mutable = [[BTMutableApplePayPaymentMethod alloc] init];
    mutable.nonce = @"a-nonce";
});

describe(@"mutableCopy", ^{
    it(@"returns a BTMutableApplyPayPaymentMethod", ^{
        BTApplePayPaymentMethod *copy = [mutable mutableCopy];
        expect(copy).to.beKindOf([BTMutableApplePayPaymentMethod class]);
        expect(copy.nonce).to.equal(@"a-nonce");
    });
});

describe(@"copy", ^{
    it(@"returns a BTApplyPayPaymentMethod", ^{
        BTApplePayPaymentMethod *copy = [mutable copy];
        expect(copy).to.beKindOf([BTApplePayPaymentMethod class]);
        expect(copy.nonce).to.equal(@"a-nonce");
    });
});


describe(@"nonce", ^{
    it(@"is readonly", ^{
        expect(mutable).to.respondTo(@selector(setNonce:));
        mutable.nonce = @"xxx";
        expect(mutable.nonce).to.equal(@"xxx");
    });
});

SpecEnd