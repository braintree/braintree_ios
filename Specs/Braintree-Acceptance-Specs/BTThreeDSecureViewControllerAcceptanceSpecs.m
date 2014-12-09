#import "BTThreeDSecureViewController.h"
#import "BTClient+Testing.h"
#import "KIFUITestActor+BTWebView.h"

@interface BTThreeDSecureViewController_AcceptanceSpecHelper : NSObject

@property (nonatomic, strong) BTClient *client;

@end

@implementation BTThreeDSecureViewController_AcceptanceSpecHelper

- (void)withClient:(void (^)(BTClient *client))completion {
    if (self.client) {
        completion(self.client);
    } else {
        __block BOOL fetching = NO;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            fetching = YES;
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                    BTClientTestConfigurationKeyCustomer:@YES,
                                                    BTClientTestConfigurationKeyClientTokenVersion: @2,
                                                    BTClientTestConfigurationKeyMerchantAccountIdentifier: @"three_d_secure_merchant_account",
                                                    }
                                       completion:^(BTClient *client) {
                                           self.client = client;
                                           completion(client);
                                       }];
        });
        NSAssert(fetching, @"Cannot call withClient while already fetching a client");
    }
}

- (void)lookupCard:(NSString *)number completion:(void (^)(BTThreeDSecureLookup *lookup))completion {
    [self withClient:^(BTClient *client) {
        BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
        request.number = number;
        request.expirationMonth = @"12";
        request.expirationYear = @"2020";
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

- (void)fetchThreeDSecureVerificationInfo:(NSString *)nonce completion:(void (^)(NSDictionary *response))completion {
    [self withClient:^(BTClient *client) {
        [client fetchNonceThreeDSecureVerificationInfo:nonce
                                               success:^(NSDictionary *threeDSecureInfo){
                                                   completion(threeDSecureInfo);
                                               } failure:^(__unused NSError *error){
                                                   completion(nil);
                                               }];
    }];
}

@end

SpecBegin(BTThreeDSecureViewController_Acceptance)

describe(@"3D Secure View Controller", ^{

    __block BTThreeDSecureViewController_AcceptanceSpecHelper *helper;
    beforeEach(^{
        helper = [[BTThreeDSecureViewController_AcceptanceSpecHelper alloc] init];
    });

    context(@"cardholder enrolled, successful authentication, successful signature verification - YYY", ^{
        it(@"successfully authenticates a user when they enter their password", ^{
            __block BTThreeDSecureLookup *lookup;
            waitUntil(^(DoneCallback done) {
                [helper lookupCard:@"4000000000000002" completion:^(BTThreeDSecureLookup *threeDSecureLookup){
                    lookup = threeDSecureLookup;
                    done();
                }];
            });

            // Setup test subject
            BTThreeDSecureViewController *threeDSecureViewController = [[BTThreeDSecureViewController alloc] initWithLookup:lookup];

            // Setup mock delegate for receiving completion messages
            id mockDelegate = [OCMockObject mockForProtocol:@protocol(BTThreeDSecureViewControllerDelegate)];

            __block NSString *nonceReceivedByDelegate;
            id delegateExpectation = [mockDelegate expect];
            [delegateExpectation andDo:^(NSInvocation *invocation){
                void (^passedBlock)(BTThreeDSecureViewControllerCompletionStatus);
                [invocation getArgument:&passedBlock atIndex:4]; // completion: of threeDSecureViewController:didAuthenticateNonce:completion:
                dispatch_async(dispatch_get_main_queue(), ^{
                    passedBlock(BTThreeDSecureViewControllerCompletionStatusSuccess);
                });
            }];
            [delegateExpectation andDo:^(NSInvocation *invocation) {
                [invocation getArgument:&nonceReceivedByDelegate atIndex:3]; // didAuthenticateNonce: of threeDSecureViewController:didAuthenticateNonce:completion:
            }];

            [delegateExpectation threeDSecureViewController:threeDSecureViewController
                                       didAuthenticateNonce:[OCMArg isNotNil]
                                                 completion:OCMOCK_ANY];

            [[mockDelegate expect] threeDSecureViewControllerDidFinish:threeDSecureViewController];
            threeDSecureViewController.delegate = mockDelegate;

            // Run 3DS UI: user authenticates successfully
            [system presentViewController:threeDSecureViewController
withinNavigationControllerWithNavigationBarClass:nil
                             toolbarClass:nil
                       configurationBlock:^(id viewController) {
                       }];

            [tester waitForViewWithAccessibilityLabel:@"Please submit your Verified by Visa password." traits:UIAccessibilityTraitStaticText];
            [tester tapUIWebviewXPathElement:@"//input[@name=\"external.field.password\"]"];
            [tester enterTextIntoCurrentFirstResponder:@"1234"];
            [tester tapViewWithAccessibilityLabel:@"Submit"];

            [mockDelegate verifyWithDelay:60];

            expect(nonceReceivedByDelegate).to.equal(lookup.nonce);

            waitUntil(^(DoneCallback done) {
                [helper fetchThreeDSecureVerificationInfo:nonceReceivedByDelegate
                                               completion:^(NSDictionary *response) {
                                                   expect(response[@"reportStatus"]).to.equal(@"authenticate_successful");
                                                   done();
                                               }];
            });
        });
    });
});

SpecEnd
