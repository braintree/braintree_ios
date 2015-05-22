#import "BTThreeDSecure.h"
#import "BTThreeDSecureAuthenticationViewController.h"
#import "BTClient_Internal.h"
#import "BTCardPaymentMethod_Mutable.h"

SpecBegin(BTThreeDSecure)

__block BTClient *client;
__block id<BTPaymentMethodCreationDelegate> delegate;
__block NSString *originalNonce_lookupEnrolledAuthenticationNotRequired = @"some-credit-card-nonce-where-3ds-succeeds-without-user-authentication";
__block NSString *originalNonce_lookupEnrolledAuthenticationRequired = @"some-credit-card-nonce-where-3ds-succeeds-after-user-authentication";
__block NSString *originalNonce_lookupCardNotEnrolled = @"some-credit-card-nonce-where-card-is-not-enrolled-for-3ds";
__block NSString *originalNonce_lookupFails = @"some-credit-card-nonce-where-3ds-fails";

beforeEach(^{
    client = [OCMockObject mockForClass:[BTClient class]];
    delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

    [[(OCMockObject *)client stub] postAnalyticsEvent:OCMOCK_ANY];

    id clientStub_lookupSucceedsAuthenticationRequired = [(OCMockObject *)client stub];
    [clientStub_lookupSucceedsAuthenticationRequired andDo:^(NSInvocation *invocation) {
        BTClientThreeDSecureLookupSuccessBlock block;
        [invocation getArgument:&block atIndex:4];
        BTThreeDSecureLookupResult *lookup = [[BTThreeDSecureLookupResult alloc] init];
        lookup.acsURL = [NSURL URLWithString:@"http://acs.example.com"];
        lookup.PAReq = @"some-pareq";
        lookup.termURL = [NSURL URLWithString:@"http://gateway.example.com/term"];
        lookup.MD = @"some-md";
        block(lookup);
    }];
    [clientStub_lookupSucceedsAuthenticationRequired lookupNonceForThreeDSecure:originalNonce_lookupEnrolledAuthenticationRequired
                                                              transactionAmount:OCMOCK_ANY
                                                                        success:[OCMArg isNotNil]
                                                                        failure:OCMOCK_ANY];

    id clientStub_lookupSucceedsAuthenticationNotRequired = [(OCMockObject *)client stub];
    [clientStub_lookupSucceedsAuthenticationNotRequired andDo:^(NSInvocation *invocation) {
        BTCardPaymentMethod *card = [OCMockObject mockForClass:[BTCardPaymentMethod class]];
        [[[(OCMockObject *)card stub] andReturn:@"valid_new_test_nonce"] nonce];
        [[[(OCMockObject *)card stub] andReturn:[BTThreeDSecureInfo infoWithLiabilityShiftPossible:YES liabilityShifted:YES]] threeDSecureInfo];
        BTThreeDSecureLookupResult *lookup = [[BTThreeDSecureLookupResult alloc] init];
        lookup.card = card;
        BTClientThreeDSecureLookupSuccessBlock block;
        [invocation getArgument:&block atIndex:4];
        block(lookup);
    }];
    [clientStub_lookupSucceedsAuthenticationNotRequired lookupNonceForThreeDSecure:originalNonce_lookupEnrolledAuthenticationNotRequired
                                                                 transactionAmount:OCMOCK_ANY
                                                                           success:[OCMArg isNotNil]
                                                                           failure:OCMOCK_ANY];

    id clientStub_lookupFails = [(OCMockObject *)client stub];
    [clientStub_lookupFails andDo:^(NSInvocation *invocation) {
        BTClientFailureBlock block;
        [invocation getArgument:&block atIndex:5];
        block([NSError errorWithDomain:BTBraintreeAPIErrorDomain code:BTServerErrorUnexpectedError userInfo:nil]);
    }];
    [clientStub_lookupFails lookupNonceForThreeDSecure:originalNonce_lookupFails
                                     transactionAmount:OCMOCK_ANY
                                               success:[OCMArg isNotNil]
                                               failure:OCMOCK_ANY];
});

describe(@"initialization", ^{
    it(@"requires a a client", ^{
        expect([[BTThreeDSecure alloc] initWithClient:nil delegate:delegate]).to.beNil();
    });

    it(@"requires a a delegate", ^{
        expect([[BTThreeDSecure alloc] initWithClient:client delegate:nil]).to.beNil();
    });
});

describe(@"BTCardPaymentMethod+BTThreeDSecureInfo category method", ^{
    it(@"returns a BTThreeDSecureInfo that reflects the values in the threeDSecureInfoDictionary property", ^{
        BTCardPaymentMethod *card = [BTCardPaymentMethod new];

        card.threeDSecureInfoDictionary = @{@"liabilityShifted": @YES, @"liabilityShiftPossible": @YES};
        expect(card.threeDSecureInfo.liabilityShifted).to.beTruthy();
        expect(card.threeDSecureInfo.liabilityShiftPossible).to.beTruthy();

        card.threeDSecureInfoDictionary = @{@"liabilityShifted": @NO, @"liabilityShiftPossible": @NO};
        expect(card.threeDSecureInfo.liabilityShifted).to.beFalsy();
        expect(card.threeDSecureInfo.liabilityShiftPossible).to.beFalsy();
    });
});

describe(@"verifyCardWithNonce:amount:", ^{
    describe(@"for a card that requires authentication", ^{
        it(@"requests presentation of a three d secure view controller", ^{
            BTThreeDSecure *threeDSecure = [[BTThreeDSecure alloc] initWithClient:client delegate:delegate];

            [[(OCMockObject *)delegate expect] paymentMethodCreator:threeDSecure
                               requestsPresentationOfViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                return [obj isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)obj visibleViewController] isKindOfClass:[BTThreeDSecureAuthenticationViewController class]];
            }]];

            [threeDSecure verifyCardWithNonce:originalNonce_lookupEnrolledAuthenticationRequired amount:[NSDecimalNumber decimalNumberWithString:@"1"]];

            [(OCMockObject *)delegate verifyWithDelay:10];
        });
    });

    describe(@"for a card that does not require authentication", ^{
        it(@"returns a nonce without any view controller interaction", ^{
            BTThreeDSecure *threeDSecure = [[BTThreeDSecure alloc] initWithClient:client delegate:delegate];

            [[(OCMockObject *)delegate expect] paymentMethodCreator:[OCMArg any] didCreatePaymentMethod:[OCMArg checkWithBlock:^BOOL(id obj) {
                if (![obj isKindOfClass:[BTCardPaymentMethod class]]) {
                    return NO;
                }
                BTCardPaymentMethod *cardPaymentMethod = obj;
                if (![cardPaymentMethod.nonce isKindOfClass:[NSString class]] || [cardPaymentMethod.nonce isEqualToString:@""]) {
                    return NO;
                }
                // Expect liability shift possible and liability shifted
                if (!cardPaymentMethod.threeDSecureInfo.liabilityShiftPossible || !cardPaymentMethod.threeDSecureInfo.liabilityShifted) {
                    return NO;
                }
                return YES;
            }]];

            [threeDSecure verifyCardWithNonce:originalNonce_lookupEnrolledAuthenticationNotRequired amount:[NSDecimalNumber decimalNumberWithString:@"1"]];

            [(OCMockObject *)delegate verifyWithDelay:10];
        });
    });
    
    describe(@"for a card that is not enrolled", ^{
        it(@"returns a card including new nonce and appropriate threeDSecureInfo", ^{
            
            id clientStub_lookupSucceedsCardNotEnrolled = [(OCMockObject *)client stub];
            [clientStub_lookupSucceedsCardNotEnrolled andDo:^(NSInvocation *invocation) {
                BTCardPaymentMethod *card = [OCMockObject mockForClass:[BTCardPaymentMethod class]];
                [[[(OCMockObject *)card stub] andReturn:@"valid_new_test_nonce"] nonce];
                [[[(OCMockObject *)card stub] andReturn:[BTThreeDSecureInfo infoWithLiabilityShiftPossible:NO liabilityShifted:NO]] threeDSecureInfo];
                BTThreeDSecureLookupResult *lookup = [[BTThreeDSecureLookupResult alloc] init];
                lookup.card = card;
                BTClientThreeDSecureLookupSuccessBlock block;
                [invocation getArgument:&block atIndex:4];
                block(lookup);
            }];
            [clientStub_lookupSucceedsCardNotEnrolled lookupNonceForThreeDSecure:originalNonce_lookupCardNotEnrolled
                                                               transactionAmount:OCMOCK_ANY
                                                                         success:[OCMArg isNotNil]
                                                                         failure:OCMOCK_ANY];
            
            BTThreeDSecure *threeDSecure = [[BTThreeDSecure alloc] initWithClient:client delegate:delegate];
            
            [[(OCMockObject *)delegate expect] paymentMethodCreator:[OCMArg any] didCreatePaymentMethod:[OCMArg checkWithBlock:^BOOL(id obj) {
                if (![obj isKindOfClass:[BTCardPaymentMethod class]]) {
                    return NO;
                }
                BTCardPaymentMethod *cardPaymentMethod = obj;
                if (![cardPaymentMethod.nonce isKindOfClass:[NSString class]] || [cardPaymentMethod.nonce isEqualToString:@""]) {
                    return NO;
                }
                // Expect liability shift not possible and liability not shifted
                if (cardPaymentMethod.threeDSecureInfo.liabilityShiftPossible || cardPaymentMethod.threeDSecureInfo.liabilityShifted) {
                    return NO;
                }
                return YES;
            }]];
            
            [threeDSecure verifyCardWithNonce:originalNonce_lookupCardNotEnrolled amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
            
            [(OCMockObject *)delegate verifyWithDelay:10];
        });
    });

    describe(@"when lookup fails due to server error", ^{
        it(@"passes the error back to the caller", ^{
            BTThreeDSecure *threeDSecure = [[BTThreeDSecure alloc] initWithClient:client delegate:delegate];

            [[(OCMockObject *)delegate expect] paymentMethodCreator:[OCMArg any] didFailWithError:[OCMArg isNotNil]];

            [threeDSecure verifyCardWithNonce:originalNonce_lookupFails amount:[NSDecimalNumber decimalNumberWithString:@"1"]];

            [(OCMockObject *)delegate verifyWithDelay:10];
        });
    });
});

describe(@"convenience methods", ^{
    describe(@"verifyCard:amount:", ^{
        it(@"delegates to verifyCardWithNonce:amount:", ^{
            BTCardPaymentMethod *mockCard = [OCMockObject mockForClass:[BTCardPaymentMethod class]];
            [[[(OCMockObject *)mockCard stub] andReturn:@"some-nonce"] nonce];

            BTThreeDSecure *threeDSecure = [[BTThreeDSecure alloc] initWithClient:client delegate:delegate];

            OCMockObject *partialMockThreeDSecure = [OCMockObject partialMockForObject:threeDSecure];
            [[partialMockThreeDSecure expect] verifyCardWithNonce:mockCard.nonce amount:[OCMArg any]];

            [threeDSecure verifyCard:mockCard amount:[NSDecimalNumber decimalNumberWithString:@"1"]];

            [partialMockThreeDSecure verify];
        });
    });

    describe(@"verifyCardWithDetails:amount:", ^{
        it(@"delegates to verifyCardWithNonce:amount:", ^{
            BTClientCardRequest *mockRequest = [OCMockObject mockForClass:[BTClientCardRequest class]];
            BTCardPaymentMethod *mockCard = [OCMockObject mockForClass:[BTCardPaymentMethod class]];
            [[[(OCMockObject *)mockCard stub] andReturn:@"some-nonce"] nonce];

            [[[(OCMockObject *)client stub] andDo:^(NSInvocation *invocation) {
                BTClientCardSuccessBlock successBlock;
                [invocation getArgument:&successBlock atIndex:3];
                successBlock(mockCard);
            }] saveCardWithRequest:mockRequest success:OCMOCK_ANY failure:OCMOCK_ANY];

            BTThreeDSecure *threeDSecure = [[BTThreeDSecure alloc] initWithClient:client delegate:delegate];

            OCMockObject *partialMockThreeDSecure = [OCMockObject partialMockForObject:threeDSecure];
            [[partialMockThreeDSecure expect] verifyCardWithNonce:mockCard.nonce amount:[OCMArg any]];
            
            [threeDSecure verifyCardWithDetails:mockRequest amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
            
            [partialMockThreeDSecure verify];
        });
    });
});

SpecEnd
