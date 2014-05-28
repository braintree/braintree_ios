#import "BTOfflineClientBackend.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTMutablePayPalPaymentMethod.h"

SpecBegin(BTOfflineClientBackend)

describe(@"all cards", ^{
    it(@"initially retrives an empty list", ^{
        BTOfflineClientBackend *offlineClientBackend = [BTOfflineClientBackend new];

        expect([offlineClientBackend allPaymentMethods]).to.haveCountOf(0);
    });

    it(@"returns the most recently added cards first", ^{
        BTOfflineClientBackend *offlineClientBackend = [BTOfflineClientBackend new];

        [offlineClientBackend addPaymentMethod:({
            BTMutablePaymentMethod *card = [BTMutablePaymentMethod new];
            card.nonce = @"first";
            card;
        })];
        [offlineClientBackend addPaymentMethod:({
            BTMutablePaymentMethod *card = [BTMutablePaymentMethod new];
            card.nonce = @"second";
            card;
        })];

        expect([[offlineClientBackend allPaymentMethods][0] nonce]).to.equal(@"second");
        expect([[offlineClientBackend allPaymentMethods][1] nonce]).to.equal(@"first");
    });
});

describe(@"add payment method", ^{
    it(@"adds a card to the list", ^{
        BTOfflineClientBackend *offlineClientBackend = [BTOfflineClientBackend new];

        BTMutableCardPaymentMethod *card = [BTMutableCardPaymentMethod new];
        [card setNonce:@"a nonce"];
        [card setTypeString:@"Visa"];

        [offlineClientBackend addPaymentMethod:card];

        expect([offlineClientBackend allPaymentMethods]).to.haveCountOf(1);
        expect([[offlineClientBackend allPaymentMethods] firstObject]).to.equal(card);
    });

    it(@"adds a PayPal account to the list", ^{
        BTOfflineClientBackend *offlineClientBackend = [BTOfflineClientBackend new];
        BTMutablePayPalPaymentMethod *payPalPaymentMethod = [BTMutablePayPalPaymentMethod new];
        [payPalPaymentMethod setNonce:@"1234"];
        [payPalPaymentMethod setEmail:@"email@example.com"];

        [offlineClientBackend addPaymentMethod:payPalPaymentMethod];

        expect([[[offlineClientBackend allPaymentMethods] firstObject] nonce]).to.equal(@"1234");
        expect([[[offlineClientBackend allPaymentMethods] firstObject] email]).to.equal(@"email@example.com");
        expect([[offlineClientBackend allPaymentMethods] firstObject]).to.equal(payPalPaymentMethod);
    });

    it(@"has no persistence from instance to instance", ^{
        BTOfflineClientBackend *offlineClientBackend = [BTOfflineClientBackend new];

        BTMutablePaymentMethod *card = [BTMutablePaymentMethod new];
        [card setNonce:@"a nonce"];

        [offlineClientBackend addPaymentMethod:card];

        BTOfflineClientBackend *secondOfflineClientBackend = [BTOfflineClientBackend new];
        
        expect([secondOfflineClientBackend allPaymentMethods]).to.haveCountOf(0);
    });
});

SpecEnd
