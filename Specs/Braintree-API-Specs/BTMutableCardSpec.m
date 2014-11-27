#import "BTMutableCardPaymentMethod.h"

SpecBegin(BTMutableCardPaymentMethod)

describe(@"init", ^{
    it(@"initializes a mutable instance", ^{
        BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];

        expect(card).to.beKindOf([BTMutableCardPaymentMethod class]);
        expect(card.isLocked).to.equal(NO);
        expect(card.nonce).to.beNil();
        expect(card.type).to.equal(BTCardTypeUnknown);
        expect(card.typeString).to.equal(@"Card");
        expect(card.lastTwo).to.beNil();
    });
});

describe(@"mutability", ^{
    describe(@"setLocked:", ^{
        it(@"sets the locked flag", ^{
            BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];
            card.locked = YES;
            expect(card.isLocked).to.beTruthy();
        });
    });

    describe(@"setNonce:", ^{
        it(@"sets the nonce", ^{
            BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];
            card.nonce = @"a_nonce";
            expect(card.nonce).to.equal(@"a_nonce");
        });
    });

    describe(@"setType", ^{
        it(@"sets the type", ^{
            BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];
            card.type = BTCardTypeDiscover;

            expect(card.type).to.equal(BTCardTypeDiscover);
        });

        it(@"sets the type string", ^{
            BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];
            card.type = BTCardTypeDiscover;

            expect(card.typeString).to.equal(@"Discover");
        });
    });

    describe(@"setTypeString", ^{
        it(@"sets the type", ^{
            BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];
            card.typeString = @"Discover";

            expect(card.type).to.equal(BTCardTypeDiscover);
        });

        it(@"sets the type string", ^{
            BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];
            card.typeString = @"Discover";

            expect(card.typeString).to.equal(@"Discover");
        });
    });

    describe(@"setLastTwo", ^{
        it(@"sets is last two", ^{
            BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];
            card.lastTwo = @"11";

            expect(card.lastTwo).to.equal(@"11");
        });
    });

    describe(@"setDescription", ^{
        it(@"sets the description", ^{
            BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];
            card.description = @"Card Ending in 8888";

            expect([card description]).to.equal(@"Card Ending in 8888");
        });
    });
});

SpecEnd
