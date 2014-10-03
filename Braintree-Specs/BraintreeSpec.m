#import "Braintree.h"
#import "Braintree_Internal.h"

#import "BTLogger.h"

#import <Braintree/BTClient+Offline.h>
#import <Braintree/BTPayPalButton.h>
#import <Braintree/BTClientToken.h>

SpecBegin(Braintree)

__block Braintree *braintree;

beforeEach(^{
    NSString *clientToken = [BTClient offlineTestClientTokenWithAdditionalParameters:nil];
    braintree = [Braintree braintreeWithClientToken:clientToken];

});

describe(@"tokenizeCardWithNumber:expirationMonth:expirationYear:completion:", ^{
    it(@"tokenizes a valid card", ^{
        waitUntil(^(DoneCallback done){
            [braintree tokenizeCardWithNumber:@"4111111111111111"
                              expirationMonth:@"12"
                               expirationYear:@"2020"
                                   completion:^(NSString *nonce, NSError *error) {
                                       expect(nonce).to.beKindOf([NSString class]);
                                       expect(nonce).notTo.equal(@"");
                                       done();
                                   }];
        });
    });

    it(@"tokenizes an invalid card", ^{
        waitUntil(^(DoneCallback done){
            [braintree tokenizeCardWithNumber:@"bad-card"
                              expirationMonth:@"12"
                               expirationYear:@"2020"
                                   completion:^(NSString *nonce, NSError *error) {
                                       expect(nonce).to.beKindOf([NSString class]);
                                       expect(nonce).notTo.equal(@"");
                                       done();
                                   }];
        });
    });
});

describe(@"dropInViewControllerWithCustomization:completion: Drop-In factory method", ^{
    it(@"constructs a Drop-In view controller", ^{
        UIViewController *dropIn = [braintree dropInViewControllerWithDelegate:nil];

        expect(dropIn).to.beKindOf([UIViewController class]);
        expect([dropIn view]).to.beKindOf([UIView class]);
    });

    it(@"returns a new instance each time", ^{
        UIViewController *dropIn1 = [braintree dropInViewControllerWithDelegate:nil];
        UIViewController *dropIn2 = [braintree dropInViewControllerWithDelegate:nil];

        expect(dropIn1).notTo.beIdenticalTo(dropIn2);
    });
});

describe(@"payPalButtonWithCompletion:", ^{
    __block Braintree *braintreeWithPayPalEnabled;

    describe(@"with PayPal enabled", ^{
        beforeEach(^{
            NSString *clientToken = [BTClient offlineTestClientTokenWithAdditionalParameters:@{BTClientTokenKeyPayPalEnabled: @YES}];
            braintreeWithPayPalEnabled = [Braintree braintreeWithClientToken:clientToken];

        });
        it(@"should return a payPalButton", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            BTPayPalButton *control = [braintreeWithPayPalEnabled payPalButtonWithDelegate:nil];
#pragma clang diagnostic pop
            expect(control).to.beKindOf([BTPayPalButton class]);
        });
    });

    describe(@"with PayPal disabled", ^{
        it(@"should not return a payPalButton", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            UIControl *control = [braintree payPalButtonWithDelegate:nil];
#pragma clang diagnostic pop
            expect(control).to.beNil;
        });
    });
});

describe(@"paymentButtonWithDelegate:paymentProviderTypes:", ^{
    it(@"returns a PaymentButton with specified payment providers", ^{
        id enabledPaymentProviderTypes = [NSOrderedSet orderedSetWithObjects:@(BTPaymentProviderTypePayPal), nil];
        BTPaymentButton *button = [braintree paymentButtonWithDelegate:nil paymentProviderTypes:enabledPaymentProviderTypes];

        expect(button).to.beKindOf([BTPaymentButton class]);
        expect(button.enabledPaymentProviderTypes).to.equal(enabledPaymentProviderTypes);
    });
});

describe(@"paymentProviderWithDelegate", ^{
    it(@"provides a configured BTPaymentProvider", ^{
        id delegate = [OCMockObject niceMockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

        BTPaymentProvider *provider = [braintree paymentProviderWithDelegate:delegate];
        expect(provider.client).to.equal(braintree.client);
        expect(provider.delegate).to.equal(delegate);
    });
});

describe(@"libraryVersion", ^{
    it(@"returns the current version number based on the podspec", ^{
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\A\\d+\\.\\d+\\.\\d+\\Z"
                                                                               options:0
                                                                                 error:NULL];
        NSString *version = [Braintree libraryVersion];

        expect([regex numberOfMatchesInString:version
                                      options:0
                                        range:NSMakeRange(0, [version length])]).to.equal(1);
    });
});


SpecEnd