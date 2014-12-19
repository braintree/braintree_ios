#import "BTThreeDSecure.h"
#import "BTThreeDSecureAuthenticationViewController.h"

SpecBegin(BTThreeDSecure)

describe(@"verifyCardWithNonce:amount:", ^{
    __block BTClient *client;
    __block id<BTPaymentMethodCreationDelegate> delegate;
    __block NSString *originalNonce_lookupEnrolledAuthenticationNotRequired = @"some-credit-card-nonce-where-3ds-succeeds-without-user-authentication";
    __block NSString *originalNonce_lookupEnrolledAuthenticationRequired = @"some-credit-card-nonce-where-3ds-succeeds-after-user-authentication";
    __block NSString *originalNonce_lookupFails = @"some-credit-card-nonce-where-3ds-fails";
    __block NSString *upgradedNonce_lookupEnrolledThreeDSecure = @"fake-3ds-lookup-enrolled-nonce";

    beforeEach(^{
        client = [OCMockObject mockForClass:[BTClient class]];
        delegate = [OCMockObject mockForProtocol:@protocol(BTPaymentMethodCreationDelegate)];

        id clientStub_lookupSucceedsAuthenticationRequired = [(OCMockObject *)client stub];
        [clientStub_lookupSucceedsAuthenticationRequired andDo:^(NSInvocation *invocation) {
            BTClientThreeDSecureLookupSuccessBlock block = [invocation getArgumentAtIndexAsObject:4];
            BTThreeDSecureLookupResult *lookup = [[BTThreeDSecureLookupResult alloc] init];
            lookup.acsURL = [NSURL URLWithString:@"http://acs.example.com"];
            block(lookup, nil);
        }];
        [clientStub_lookupSucceedsAuthenticationRequired lookupNonceForThreeDSecure:originalNonce_lookupEnrolledAuthenticationRequired
                             transactionAmount:OCMOCK_ANY
                                       success:[OCMArg isNotNil]
                                       failure:OCMOCK_ANY];

        id clientStub_lookupSucceedsAuthenticationNotRequired = [(OCMockObject *)client stub];
        [clientStub_lookupSucceedsAuthenticationNotRequired andDo:^(NSInvocation *invocation) {
            BTClientThreeDSecureLookupSuccessBlock block = [invocation getArgumentAtIndexAsObject:4];
            block(nil, upgradedNonce_lookupEnrolledThreeDSecure);
        }];
        [clientStub_lookupSucceedsAuthenticationNotRequired lookupNonceForThreeDSecure:originalNonce_lookupEnrolledAuthenticationNotRequired
                             transactionAmount:OCMOCK_ANY
                                       success:[OCMArg isNotNil]
                                       failure:OCMOCK_ANY];
        
        id clientStub_lookupFails = [(OCMockObject *)client stub];
        [clientStub_lookupFails andDo:^(NSInvocation *invocation) {
            BTClientFailureBlock block = [invocation getArgumentAtIndexAsObject:5];
            block([NSError errorWithDomain:BTBraintreeAPIErrorDomain code:BTServerErrorUnexpectedError userInfo:nil]);
        }];
        [clientStub_lookupFails lookupNonceForThreeDSecure:originalNonce_lookupFails
                                         transactionAmount:OCMOCK_ANY
                                                   success:[OCMArg isNotNil]
                                                   failure:OCMOCK_ANY];
    });
    
    describe(@"for a card that requires authentication", ^{
        it(@"requests presentation of a three d secure view controller", ^{
            BTThreeDSecure *threeDSecure = [[BTThreeDSecure alloc] initWithClient:client delegate:delegate];
            
            [[(OCMockObject *)delegate expect] paymentMethodCreator:threeDSecure
                               requestsPresentationOfViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                return [obj isKindOfClass:[BTThreeDSecureAuthenticationViewController class]];
            }]];
            
            [threeDSecure verifyCardWithNonce:originalNonce_lookupEnrolledAuthenticationRequired amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
            
            [(OCMockObject *)delegate verifyWithDelay:10];
        });
    });

    describe(@"for a card that does not require authentication", ^{
        it(@"returns a nonce without any view controller interaction", ^{
            BTThreeDSecure *threeDSecure = [[BTThreeDSecure alloc] initWithClient:client delegate:delegate];
            
            [[(OCMockObject *)delegate expect] paymentMethodCreator:[OCMArg any] didCreatePaymentMethod:[OCMArg checkWithBlock:^BOOL(id obj) {
                return [obj isKindOfClass:[BTCardPaymentMethod class]];
            }]];
            
            [threeDSecure verifyCardWithNonce:originalNonce_lookupEnrolledAuthenticationNotRequired amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
            
            [(OCMockObject *)delegate verifyWithDelay:10];
        });
    });

    describe(@"when lookup fails", ^{
        it(@"passes the error back to the caller", ^{
            BTThreeDSecure *threeDSecure = [[BTThreeDSecure alloc] initWithClient:client delegate:delegate];
            
            [[(OCMockObject *)delegate expect] paymentMethodCreator:[OCMArg any] didFailWithError:[OCMArg isNotNil]];

            [threeDSecure verifyCardWithNonce:originalNonce_lookupFails amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
            
            [(OCMockObject *)delegate verifyWithDelay:10];
        });
    });
});

SpecEnd
