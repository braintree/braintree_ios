#import "BTMutableCard.h"

SpecBegin(BTMutableCard)

describe(@"init", ^{
    it(@"initializes a mutable instance", ^{
        BTMutableCard *card = [[BTMutableCard alloc] init];

        expect(card).to.beKindOf([BTMutableCard class]);
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
            BTMutableCard *card = [[BTMutableCard alloc] init];
            card.locked = YES;
            expect(card.isLocked).to.beTruthy();
        });
    });

    describe(@"setNonce:", ^{
        it(@"sets the nonce", ^{
            BTMutableCard *card = [[BTMutableCard alloc] init];
            card.nonce = @"a_nonce";
            expect(card.nonce).to.equal(@"a_nonce");
        });
    });

    describe(@"setType", ^{
        it(@"sets the type", ^{
            BTMutableCard *card = [[BTMutableCard alloc] init];
            card.type = BTCardTypeDiscover;

            expect(card.type).to.equal(BTCardTypeDiscover);
        });

        it(@"sets the type string", ^{
            BTMutableCard *card = [[BTMutableCard alloc] init];
            card.type = BTCardTypeDiscover;

            expect(card.typeString).to.equal(@"Discover");
        });
    });

    describe(@"setTypeString", ^{
        it(@"sets the type", ^{
            BTMutableCard *card = [[BTMutableCard alloc] init];
            card.typeString = @"Discover";

            expect(card.type).to.equal(BTCardTypeDiscover);
        });

        it(@"sets the type string", ^{
            BTMutableCard *card = [[BTMutableCard alloc] init];
            card.typeString = @"Discover";

            expect(card.typeString).to.equal(@"Discover");
        });
    });

    describe(@"setLastTwo", ^{
        it(@"sets is last two", ^{
            BTMutableCard *card = [[BTMutableCard alloc] init];
            card.lastTwo = @"11";

            expect(card.lastTwo).to.equal(@"11");
        });
    });

    describe(@"setDescription", ^{
        it(@"sets the description", ^{
            BTMutableCard *card = [[BTMutableCard alloc] init];
            card.description = @"Card Ending in 8888";

            expect([card description]).to.equal(@"Card Ending in 8888");
        });
    });
});

SpecEnd