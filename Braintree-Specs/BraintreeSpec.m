#import "Braintree.h"
#import "Braintree_Internal.h"

#import <Braintree/BTClient+Offline.h>
#import <Braintree/BTPayPalButton.h>
#import <Braintree/BTClientToken+BTPayPal.h>

SpecBegin(Braintree)

__block Braintree *braintree;

beforeEach(^{
    NSString *clientToken = [BTClient offlineTestClientTokenWithAdditionalParameters:nil];
    braintree = [Braintree braintreeWithClientToken:clientToken];

});

describe(@"tokenizeCardWithNumber:expirationMonth:expirationYear:completion:", ^{
    it(@"tokenizes a valid card", ^AsyncBlock{
        [braintree tokenizeCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                           expirationYear:@"2020"
                               completion:^(NSString *nonce, NSError *error) {
                                   expect(nonce).to.beKindOf([NSString class]);
                                   expect(nonce).notTo.equal(@"");
                                   done();
                               }];
    });

    it(@"tokenizes an invalid card", ^AsyncBlock{
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

describe(@"paymentButtonWithPaymentAuthorizationTypes:delegate:", ^{
    it(@"returns a PaymentButton with specified authorization types enabled", ^{
        id enabledPaymentAuthorizationTypes = [NSOrderedSet orderedSetWithObjects:@(BTPaymentAuthorizationTypePayPal), nil];
        BTPaymentButton *button = [braintree paymentButtonWithPaymentAuthorizationTypes:enabledPaymentAuthorizationTypes delegate:nil];

        expect(button).to.beKindOf([BTPaymentButton class]);
        expect(button.enabledPaymentAuthorizationTypes).to.equal(enabledPaymentAuthorizationTypes);
    });
});

describe(@"authorizePayment:delegate:", ^{
    it(@"provides a convinience around BTPaymentAuthorizer", ^{
        id delegate = [OCMockObject niceMockForProtocol:@protocol(BTPaymentAuthorizerDelegate)];
        id authorizer = [OCMockObject niceMockForClass:[BTPaymentAuthorizer class]];
        BTPaymentAuthorizationType type = BTPaymentAuthorizationTypePayPal;

        braintree.authorizer = authorizer;

        [(BTPaymentAuthorizer *)[authorizer expect] setDelegate:delegate];
        [(BTPaymentAuthorizer *)[authorizer expect] authorize:type];

        [braintree authorizePayment:type
                           delegate:delegate];

        [authorizer verify];
        [authorizer stopMocking];
    });

    it(@"utilizes the an authorizer with the same client as Braintree", ^{
        expect(braintree.authorizer.client).to.equal(braintree.client);
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