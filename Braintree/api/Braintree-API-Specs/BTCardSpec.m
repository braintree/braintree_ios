#import "BTMutableCard.h"

SpecBegin(BTCard)

describe(@"init", ^{
    it(@"creates a card with default empty state", ^{
        BTCard *card = [BTCard new];

        expect(card.isLocked).to.beFalsy();
        expect(card.nonce).to.beNil();
        expect(card.lastTwo).to.beNil();
        expect(card.challengeQuestions).to.beNil();
    });
});

describe(@"card type", ^{
  it(@"is initially unknown", ^{
    BTMutableCard *card = [[BTMutableCard alloc] init];
    expect(card.type).to.equal(BTCardTypeUnknown);
    expect(card.typeString).to.equal(@"Card");
  });

  it(@"has a typeString", ^{
    BTMutableCard *card = [[BTMutableCard alloc] init];
    card.type = BTCardTypeAMEX;
    expect(card.typeString).to.equal(@"American Express");
    card.type = BTCardTypeVisa;
    expect(card.typeString).to.equal(@"Visa");
  });

  it(@"sets type using any case typeString", ^{
    BTMutableCard *card = [[BTMutableCard alloc] init];
    card.typeString = @"Mastercard";
    expect(card.type).to.equal(BTCardTypeMasterCard);
    card.typeString = @"DISCOVER";
    expect(card.type).to.equal(BTCardTypeDiscover);
    card.typeString = @"china unionpay";
    expect(card.type).to.equal(BTCardTypeUnionPay);
  });
});

describe(@"description", ^{
    it(@"returns a predetermined palatable representation of the card", ^{
        BTMutableCard *card = [[BTMutableCard alloc] init];
        card.description = @"A cool credit card";
        expect([card description]).to.contain(@"A cool credit card");
    });
});

describe(@"debug descripton", ^{
    it(@"returns a useful representation of the card", ^{
        BTMutableCard *card = [[BTMutableCard alloc] init];
        card.description = @"A cool credit card";
        card.nonce = [[NSUUID UUID] UUIDString];
        card.type = BTCardTypeMaestro;

        expect([card debugDescription]).to.contain(card.nonce);
        expect([card debugDescription]).to.contain(card.description);
        expect([card debugDescription]).to.contain(card.typeString);
    });
});

SpecEnd