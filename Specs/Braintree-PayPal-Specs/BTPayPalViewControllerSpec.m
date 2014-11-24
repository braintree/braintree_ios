#import "BTPayPalViewController_Internal.h"
#import "PayPalMobile.h"

SpecBegin(BTPayPalViewController)

__block BTClient *client;

beforeEach(^{
    client = [OCMockObject mockForClass:[BTClient class]];
});

afterEach(^{
    [(OCMockObject *)client stopMocking];
});

describe(@"initialization", ^{
    it(@"constructs a BTPayPalViewController when given a valid client", ^{
        BTPayPalViewController *payPalViewController = [[BTPayPalViewController alloc] initWithClient:client];
        expect(payPalViewController).to.beKindOf([BTPayPalViewController class]);
    });

    it(@"can accepts a client after initialization", ^{
        BTPayPalViewController *payPalViewController = [[BTPayPalViewController alloc] initWithClient:nil];
        payPalViewController.client = client;

        expect(payPalViewController).to.beKindOf([BTPayPalViewController class]);
    });
});

SpecEnd
