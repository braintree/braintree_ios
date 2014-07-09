#import "BTDropInViewController.h"

SpecBegin(BTDropInViewController)

describe(@"initialization", ^{
    it(@"sets the client", ^{
        id mockClient = [OCMockObject niceMockForClass:[BTClient class]];
        BTDropInViewController *viewController = [[BTDropInViewController alloc] initWithClient:mockClient];
        expect(viewController.client).to.beIdenticalTo(mockClient);
    });

    it(@"starts without a delegate", ^{
        BTDropInViewController *viewController = [[BTDropInViewController alloc] initWithClient:nil];

        expect(viewController.delegate).to.beNil();
    });
});

SpecEnd
