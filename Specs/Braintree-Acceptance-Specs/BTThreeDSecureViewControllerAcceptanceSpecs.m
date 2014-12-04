#import "BTThreeDSecureViewController.h"
#import "BTClient+Testing.h"
#import "KIFUITestActor+BTWebView.h"


void lookupCard(NSString * number, void (^completion)(BTThreeDSecureLookup *lookup)) {
    [BTClient testClientWithConfiguration:@{
                                            BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                            BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                            BTClientTestConfigurationKeyCustomer:@YES,
                                            BTClientTestConfigurationKeyClientTokenVersion: @2
                                            } completion:^(BTClient *client) {
                                                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                                                request.number = @"4111111111111111";
                                                request.expirationMonth = @"12";
                                                request.expirationYear = @"2015";
                                                request.shouldValidate = YES;

                                                [client saveCardWithRequest:request
                                                                    success:^(BTPaymentMethod *card) {
                                                                        [client lookupNonceForThreeDSecure:card.nonce
                                                                                         transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                                                                   success:^(BTThreeDSecureLookup *threeDSecureLookup) {
                                                                                                       completion(threeDSecureLookup);
                                                                                                   } failure:nil];
                                                                    } failure:^(__unused NSError *error) {
                                                                        completion(nil);
                                                                    }];
                                            }];
}

void fetchThreeDSecureVerificationInfo(NSString *nonce, void (^completion)(NSDictionary *response)) {
    [BTClient testClientWithConfiguration:@{
                                            BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                            BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                            BTClientTestConfigurationKeyCustomer:@YES,
                                            BTClientTestConfigurationKeyClientTokenVersion: @2
                                            } completion:^(BTClient *client) {
                                                [client fetchNonceThreeDSecureVerificationInfo:nonce
                                                                                       success:^(NSDictionary *threeDSecureInfo){
                                                                                           completion(threeDSecureInfo);
                                                                                       } failure:^(__unused NSError *error){
                                                                                           completion(nil);
                                                                                       }];
                                            }];
}

SpecBegin(BTThreeDSecureViewController_Acceptance)

describe(@"3D Secure View Controller", ^{
    context(@"cardholder enrolled, successful authentication, successful signature verification - YYY", ^{
        it(@"successfully authenticates a user when they enter their password", ^{
            __block BTThreeDSecureLookup *lookup;
            waitUntil(^(DoneCallback done) {
                lookupCard(@"4111111111111111", ^(BTThreeDSecureLookup *threeDSecureLookup){
                    lookup = threeDSecureLookup;
                    done();
                });
            });

            BTThreeDSecureViewController *threeDSecureViewController = [[BTThreeDSecureViewController alloc] initWithLookup:lookup];

            id mockDelegate = [OCMockObject mockForProtocol:@protocol(BTThreeDSecureViewControllerDelegate)];

            void (^threeDSecureViewControllerDelegateAuthenticationSuccessBlock)(NSInvocation *) = ^void(NSInvocation *invocation){
                void (^passedBlock)(BTThreeDSecureViewControllerCompletionStatus);
                [invocation getArgument:&passedBlock atIndex:4]; // completion: of threeDSecureViewController:didAuthenticateNonce:completion:
                dispatch_async(dispatch_get_main_queue(), ^{
                    passedBlock(BTThreeDSecureViewControllerCompletionStatusSuccess);
                });
            };

            __block NSString *nonceReceivedByDelegate;
            id delegateExpectation = [mockDelegate expect];
            [delegateExpectation andDo:threeDSecureViewControllerDelegateAuthenticationSuccessBlock];
            [delegateExpectation andDo:^(NSInvocation *invocation) {
                [invocation getArgument:&nonceReceivedByDelegate atIndex:3]; // didAuthenticateNonce: of threeDSecureViewController:didAuthenticateNonce:completion:
            }];

            [delegateExpectation threeDSecureViewController:threeDSecureViewController
                                       didAuthenticateNonce:[OCMArg isNotNil]
                                                 completion:OCMOCK_ANY];

            [[mockDelegate expect] threeDSecureViewControllerDidFinish:threeDSecureViewController];
            threeDSecureViewController.delegate = mockDelegate;

            [system presentViewController:threeDSecureViewController
withinNavigationControllerWithNavigationBarClass:nil
                             toolbarClass:nil
                       configurationBlock:^(id viewController) {
                       }];

            [tester waitForViewWithAccessibilityLabel:@"Please submit your Verified by Visa password." traits:UIAccessibilityTraitStaticText];
            [tester tapUIWebviewXPathElement:@"//input[@name=\"external.field.password\"]"];
            [tester enterTextIntoCurrentFirstResponder:@"1234"];
            [tester tapViewWithAccessibilityLabel:@"Submit"];
            [mockDelegate verifyWithDelay:[tester executionBlockTimeout]];

            expect(nonceReceivedByDelegate).to.equal(lookup.nonce);

            waitUntil(^(DoneCallback done) {
                fetchThreeDSecureVerificationInfo(nonceReceivedByDelegate, ^(NSDictionary *response){
                    expect(response[@"threeDSecureVerification"][@"reportStatus"]).to.equal(@"authenticate_successful");
                    done();
                });
            });
        });
    });
});


SpecEnd
