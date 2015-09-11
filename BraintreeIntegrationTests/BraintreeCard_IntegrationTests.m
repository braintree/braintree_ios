#import "BTIntegrationTestsHelper.h"
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCard/BraintreeCard.h>
#import <Expecta/Expecta.h>
#import <Specta/Specta.h>

SpecBegin(BTCardClient_Integration)

describe(@"tokenizeCard:completion:", ^{
    __block BTCardClient *client;

    context(@"with validation disabled", ^{
        beforeEach(^{
            BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
            client = [[BTCardClient alloc] initWithAPIClient:apiClient];
        });

        it(@"creates an unlocked card with a nonce using an invalid card", ^{
            BTCard *card = [[BTCard alloc] init];
            card.number = @"INVALID_CARD";
            card.expirationMonth = @"XX";
            card.expirationYear = @"YYYY";

            XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
            [client tokenizeCard:card completion:^(BTTokenizedCard * _Nullable tokenized, NSError * _Nullable error) {
                expect(tokenized.paymentMethodNonce.isANonce).to.beTruthy();
                expect(error).to.beNil();
                [expectation fulfill];
            }];

            [self waitForExpectationsWithTimeout:5 handler:nil];
        });

        it(@"creates an unlocked card with a nonce using a valid card", ^{
            BTCard *card = [[BTCard alloc] init];
            card.number = @"4111111111111111";
            card.expirationMonth = @"12";
            card.expirationYear = @"2018";

            XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
            [client tokenizeCard:card completion:^(BTTokenizedCard * _Nullable tokenized, NSError * _Nullable error) {
                expect(tokenized.paymentMethodNonce.isANonce).to.beTruthy();
                expect(error).to.beNil();
                [expectation fulfill];
            }];

            [self waitForExpectationsWithTimeout:5 handler:nil];
        });
    });

    context(@"with validation enabled", ^{

        context(@"and API client uses client key", ^{

            beforeEach(^{
                BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_integration_merchant_id"];
                client = [[BTCardClient alloc] initWithAPIClient:apiClient];
            });

            it(@"returns an authorization error", ^{
                BTCard *card = [[BTCard alloc] init];
                card.shouldValidate = YES;
                card.number = @"4111111111111111";
                card.expirationMonth = @"12";
                card.expirationYear = @"2018";

                XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
                [client tokenizeCard:card completion:^(BTTokenizedCard *tokenized, NSError *error) {
                    XCTAssertNil(tokenized);
                    expect(error.domain).to.equal(BTHTTPErrorDomain);
                    expect(error.code).to.equal(BTHTTPErrorCodeClientError);
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)error.userInfo[BTHTTPURLResponseKey];
                    expect(httpResponse.statusCode).to.equal(403);
                    [expectation fulfill];
                }];
                
                [self waitForExpectationsWithTimeout:5 handler:nil];
            });
        });

        pending(@"and API client uses signed JWT", ^{

//            it(@"populates card details based on the server-side response", ^{
//                BTCard *card = [[BTCard alloc] init];
//                card.shouldValidate = YES;
//                card.number = @"5555555555554444";
//                card.expirationMonth = @"12";
//                card.expirationYear = @"2018";
//
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Tokenize card"];
//                [client tokenizeCard:card completion:^(BTTokenizedCard *tokenized, NSError *error) {
//                    expect(tokenized.cardNetwork).to.equal(BTCardNetworkMasterCard);
//                    expect(tokenized.lastTwo).to.equal(@"44");
//                    expect(tokenized.localizedDescription).to.equal(@"ending in 44");
//                    [expectation fulfill];
//                }];
//                
//                [self waitForExpectationsWithTimeout:5 handler:nil];
//            });


            //
            //        it(@"fails when the provided card number is not valid", ^{
            //            XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
            //            BTClientCardcard *card = [[BTClientCardcard alloc] init];
            //            card.number = @"4111111111111112";
            //            card.expirationMonth = @"12";
            //            card.expirationYear = @"2018";
            //            card.shouldValidate = YES;
            //            [testClient saveCardWithcard:card
            //                                    success:nil
            //                                    failure:^(NSError *error) {
            //                                        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
            //                                        expect(error.code).to.equal(BTCustomerInputErrorInvalid);
            //                                        [expectation fulfill];
            //                                    }];
            //            [self waitForExpectationsWithTimeout:10 handler:nil];
            //        });
            //
            //        it(@"fails and provides all braintree validation errors when user input is invalid", ^{
            //            XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
            //            BTClientCardcard *card = [[BTClientCardcard alloc] init];
            //            card.number = @"4111111111111112";
            //            card.expirationMonth = @"82";
            //            card.expirationYear = @"2";
            //            card.shouldValidate = YES;
            //
            //            [testClient saveCardWithcard:card
            //                                    success:nil
            //                                    failure:^(NSError *error) {
            //                                        expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).toNot.beNil();
            //
            //                                        NSDictionary *validationErrors = error.userInfo[BTCustomerInputBraintreeValidationErrorsKey];
            //                                        NSArray *fieldErrors = validationErrors[@"fieldErrors"];
            //                                        NSDictionary *creditCardFieldError = fieldErrors[0];
            //
            //                                        expect(fieldErrors).to.haveCountOf(1);
            //
            //                                        expect(creditCardFieldError[@"field"]).to.equal(@"creditCard");
            //                                        expect(creditCardFieldError[@"fieldErrors"]).to.haveCountOf(3);
            //
            //                                        expect(creditCardFieldError[@"fieldErrors"]).to.contain((@{@"field": @"expirationYear",
            //                                                                                                   @"message": @"Expiration year is invalid",
            //                                                                                                   @"code": @"81713"}));
            //                                        expect(creditCardFieldError[@"fieldErrors"]).to.contain((@{@"field": @"expirationMonth",
            //                                                                                                   @"message": @"Expiration month is invalid",
            //                                                                                                   @"code": @"81712"}));
            //                                        expect(creditCardFieldError[@"fieldErrors"]).to.contain((@{@"field": @"number",
            //                                                                                                   @"message": @"Credit card number is invalid",
            //                                                                                                   @"code": @"81715"}));
            //                                        [expectation fulfill];
            //                                    }];
            //            [self waitForExpectationsWithTimeout:10 handler:nil];
            //        });
            //
            //        it(@"saves a transactable credit card nonce", ^{
            //            XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
            //            BTClientCardcard *card = [[BTClientCardcard alloc] init];
            //            card.number = @"4111111111111111";
            //            card.expirationMonth = @"12";
            //            card.expirationYear = @"2018";
            //            card.shouldValidate = YES;
            //
            //            [testClient saveCardWithcard:card
            //                                    success:^(BTPaymentMethod *card) {
            //                                        [testClient fetchNonceInfo:card.nonce
            //                                                           success:^(NSDictionary *nonceInfo) {
            //                                                               expect(nonceInfo[@"isLocked"]).to.beFalsy();
            //                                                               expect(nonceInfo[@"isConsumed"]).to.beFalsy();
            //                                                               [expectation fulfill];
            //                                                           }
            //                                                           failure:nil];
            //                                    } failure:nil];
            //            [self waitForExpectationsWithTimeout:10 handler:nil];
            //        });

//            context(@"when merchant has CVV challenge enabled", ^{
                //            __block BTCardClient *cvvAndZipClient;
                //
                //            beforeEach(^{
                //                BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:@"development_testing_client_api_cvv_and_postal_code_verification_merchant_id"];
                //                cvvAndZipClient = [[BTCardClient alloc] initWithAPIClient:apiClient];
                //            });
                //
                //            it(@"saves a card when the challenges are provided", ^{
                //                XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
                //                BTCard *card = [[BTCard alloc] init];
                //                card.number = @"4111111111111111";
                //                card.expirationMonth = @"12";
                //                card.expirationYear = @"38";
                //                card.cvv = @"100";
                //                card.postalCode = @"15213";
                //                card.shouldValidate = YES;
                //
                //                [cvvAndZipClient tokenizeCard:card completion:^(BTTokenizedCard *tokenized, NSError *error) {
                //                    expect(tokenized.paymentMethodNonce).toNot.beNil();
                //                    expect(error).to.beNil();
                //                    [expectation fulfill];
                //                }];
                //
                //                [self waitForExpectationsWithTimeout:5 handler:nil];
                //            });
                //
                //            it(@"fails to save a card when a cvv response is incorrect", ^{
                //                XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
                //                BTCard *card = [[BTCard alloc] initWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"38" cvv:@"200"];
                //                card.postalCode = @"15213";
                //                card.shouldValidate = YES;
                //
                //                [cvvAndZipClient tokenizeCard:card completion:^(BTTokenizedCard *tokenized, NSError *error) {
                //                    expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                //                    expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                //                    expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(1);
                //                    expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"cvv");
                //                    [expectation fulfill];
                //                }];
                //
                //                [self waitForExpectationsWithTimeout:5 handler:nil];
                //            });
                //
                //            it(@"fails to save a card when a postal code response is incorrect", ^{
                //                XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client and save card"];
                //                BTClientCardcard *card = [[BTClientCardcard alloc] init];
                //                [BTClient testClientWithConfiguration:@{
                //                                                        BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_postal_code_verification_merchant_id",
                //                                                        BTClientTestConfigurationKeyPublicKey: @"client_api_postal_code_verification_public_key",
                //                                                        BTClientTestConfigurationKeyCustomer: @YES }
                //                                                async:asyncClient completion:^(BTClient *zipClient) {
                //                                                    card.number = @"4111111111111111";
                //                                                    card.expirationMonth = @"12";
                //                                                    card.expirationYear = @"38";
                //                                                    card.cvv = @"100";
                //                                                    card.postalCode = @"20000";
                //                                                    card.shouldValidate = YES;
                //                                                    [zipClient saveCardWithcard:card
                //                                                                           success:nil
                //                                                                           failure:^(NSError *error) {
                //                                                                               expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                //                                                                               expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                //                                                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(1);
                //                                                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"postalCode");
                //
                //                                                                               [expectation fulfill];
                //                                                                           }];
                //                                                }];
                //                [self waitForExpectationsWithTimeout:10 handler:nil];
                //            });
                //
                //            it(@"fails to save a card when cvv and postal code responses are both incorrect", ^{
                //                XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to save card"];
                //                BTClientCardcard *card = [[BTClientCardcard alloc] init];
                //                card.number = @"4111111111111111";
                //                card.expirationMonth = @"12";
                //                card.expirationYear = @"38";
                //                card.cvv = @"200";
                //                card.postalCode = @"20000";
                //                card.shouldValidate = YES;
                //                [cvvAndZipClient saveCardWithcard:card
                //                                             success:nil
                //                                             failure:^(NSError *error) {
                //                                                 expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                //                                                 expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                //                                                 expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(2);
                //                                                 expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"cvv");
                //                                                 expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][1][@"fieldErrors"][0][@"field"]).to.equal(@"postalCode");
                //                                                 [expectation fulfill];
                //                                             }];
                //                [self waitForExpectationsWithTimeout:10 handler:nil];
                //            });
            //        });
        });

    });

});

SpecEnd


//
//    describe(@"clients with Apple Pay activated", ^{
//        if ([PKPayment class]) {
//            it(@"can save an Apple Pay payment based on a PKPayment if Apple Pay is supported", ^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Save Apple Pay card"];
//
//                id payment = [OCMockObject partialMockForObject:[[PKPayment alloc] init]];
//                id paymentToken = [OCMockObject partialMockForObject:[[PKPaymentToken alloc] init]];
//
//                [[[payment stub] andReturn:paymentToken] token];
//                [[[payment stub] andReturnValue:OCMOCK_VALUE(NULL)] shippingAddress];
//                [[[payment stub] andReturnValue:OCMOCK_VALUE(NULL)] billingAddress];
//                [[[payment stub] andReturn:nil] shippingMethod];
//                [[[paymentToken stub] andReturn:[NSData data]] paymentData];
//                [[[paymentToken stub] andReturn:@"an amex 12345"] paymentInstrumentName];
//                [[[paymentToken stub] andReturn:PKPaymentNetworkAmex] paymentNetwork];
//                [[[paymentToken stub] andReturn:@"transaction-identifier"] transactionIdentifier];
//
//                [testClient saveApplePayPayment:payment success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
//                    expect(applePayPaymentMethod.nonce).to.beANonce();
//                    expect(applePayPaymentMethod.shippingAddress).to.beNil();
//                    expect(applePayPaymentMethod.billingAddress).to.beNil();
//                    expect(applePayPaymentMethod.shippingMethod).to.beNil();
//                    [expectation fulfill];
//                } failure:^(NSError *error) {
//                    if (error) {
//                        NSLog(@"ERROR: Make sure Apple Pay is enabled for integration_merchant_id in the Gateway.");
//                        XCTFail(@"error = %@", error);
//                    }
//                }];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//
//            it(@"can save an Apple Pay payment based on a PKPayment if Apple Pay is supported and return address information alongside the nonce", ^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Save apple pay card"];
//                id payment = [OCMockObject partialMockForObject:[[PKPayment alloc] init]];
//                id paymentToken = [OCMockObject partialMockForObject:[[PKPaymentToken alloc] init]];
//
//                ABRecordRef shippingAddress = ABPersonCreate();
//                ABRecordRef billingAddress = ABPersonCreate();
//                PKShippingMethod *shippingMethod = [PKShippingMethod summaryItemWithLabel:@"Shipping Method" amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
//                shippingMethod.detail = @"detail";
//                shippingMethod.identifier = @"identifier";
//
//                [[[payment stub] andReturn:paymentToken] token];
//                [[[payment stub] andReturnValue:OCMOCK_VALUE((void *)shippingAddress)] shippingAddress];
//                [[[payment stub] andReturnValue:OCMOCK_VALUE((void *)billingAddress)] billingAddress];
//                [[[payment stub] andReturn:shippingMethod] shippingMethod];
//                [[[paymentToken stub] andReturn:[NSData data]] paymentData];
//                [[[paymentToken stub] andReturn:@"an amex 12345"] paymentInstrumentName];
//                [[[paymentToken stub] andReturn:PKPaymentNetworkAmex] paymentNetwork];
//                [[[paymentToken stub] andReturn:@"transaction-identifier"] transactionIdentifier];
//
//                [testClient saveApplePayPayment:payment success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
//                    expect(applePayPaymentMethod.nonce).to.beANonce();
//                    expect(applePayPaymentMethod.shippingAddress == shippingAddress).to.equal(YES);
//                    expect(applePayPaymentMethod.billingAddress == billingAddress).to.equal(YES);
//                    expect(applePayPaymentMethod.shippingMethod.label).to.equal(shippingMethod.label);
//                    expect(applePayPaymentMethod.shippingMethod.amount).to.equal(shippingMethod.amount);
//                    expect(applePayPaymentMethod.shippingMethod.detail).to.equal(shippingMethod.detail);
//                    expect(applePayPaymentMethod.shippingMethod.identifier).to.equal(shippingMethod.identifier);
//                    [expectation fulfill];
//                } failure:nil];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//        }
//    });
//
//
//    describe(@"clients with PayPal activated", ^{
//        __block BTClient *testClient;
//        beforeEach(^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client"];
//            [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
//                                                     BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
//                                                     BTClientTestConfigurationKeyCustomer: @YES }
//                                            async:asyncClient completion:^(BTClient *client) {
//                                                testClient = client;
//                                                [expectation fulfill];
//                                            }];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        it(@"can save a PayPal payment method based on an auth code", ^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Save payment method"];
//            [testClient savePaypalPaymentMethodWithAuthCode:@"testAuthCode"
//                                   applicationCorrelationID:@"testCorrelationId"
//                                                    success:^(BTPayPalPaymentMethod *payPalPaymentMethod){
//                                                        expect(payPalPaymentMethod.nonce).to.beANonce();
//                                                        expect(payPalPaymentMethod.email).to.beKindOf([NSString class]);
//                                                        [expectation fulfill];
//                                                    } failure:nil];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        it(@"can save a PayPal payment method based on an auth code without a correlation id", ^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Save payment method"];
//            [testClient savePaypalPaymentMethodWithAuthCode:@"testAuthCode"
//                                   applicationCorrelationID:nil
//                                                    success:^(BTPayPalPaymentMethod *payPalPaymentMethod){
//                                                        expect(payPalPaymentMethod.nonce).to.beANonce();
//                                                        expect(payPalPaymentMethod.email).to.beKindOf([NSString class]);
//                                                        [expectation fulfill];
//                                                    } failure:nil];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        it(@"can save a PayPal payment method that includes address information when an additional address scope is set", ^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Save payment method"];
//            testClient.additionalPayPalScopes = [NSSet setWithObject:@"address"];
//            [testClient savePaypalPaymentMethodWithAuthCode:@"testAuthCode"
//                                   applicationCorrelationID:@"testCorrelationId"
//                                                    success:^(BTPayPalPaymentMethod *payPalPaymentMethod){
//                                                        expect(payPalPaymentMethod.nonce).to.beANonce();
//                                                        expect(payPalPaymentMethod.email).to.beKindOf([NSString class]);
//                                                        expect(payPalPaymentMethod.billingAddress).toNot.beNil();
//                                                        expect(payPalPaymentMethod.billingAddress.streetAddress).to.beKindOf([NSString class]);
//                                                        expect(payPalPaymentMethod.billingAddress.extendedAddress).to.beKindOf([NSString class]);
//                                                        expect(payPalPaymentMethod.billingAddress.locality).to.beKindOf([NSString class]);
//                                                        expect(payPalPaymentMethod.billingAddress.region).to.beKindOf([NSString class]);
//                                                        expect(payPalPaymentMethod.billingAddress.postalCode).to.beKindOf([NSString class]);
//                                                        expect(payPalPaymentMethod.billingAddress.countryCodeAlpha2).to.beKindOf([NSString class]);
//                                                        [expectation fulfill];
//                                                    } failure:nil];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//    });
//
//    describe(@"a client initialized with a revoked authorization fingerprint", ^{
//        beforeEach(^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Revoke authorization fingerprint"];
//            [testClient revokeAuthorizationFingerprintForTestingWithSuccess:^{
//                [expectation fulfill];
//            } failure:nil];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        it(@"invokes the failure block for list payment methods", ^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch payment methods"];
//            [testClient fetchPaymentMethodsWithSuccess:nil failure:^(NSError *error) {
//                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
//                expect(error.code).to.equal(BTMerchantIntegrationErrorUnauthorized);
//                [expectation fulfill];
//            }];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        it(@"noops for list cards if the failure block is nil", ^{
//            [testClient fetchPaymentMethodsWithSuccess:nil failure:nil];
//
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for potential async exceptions"];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//                [expectation fulfill];
//            });
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        it(@"invokes the failure block for save card", ^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Fails to save card"];
//            BTClientCardcard *card = [[BTClientCardcard alloc] init];
//            card.number = @"4111111111111111";
//            card.expirationMonth = @"12";
//            card.expirationYear = @"2018";
//            card.shouldValidate = NO;
//            [testClient saveCardWithcard:card
//                                    success:nil
//                                    failure:^(NSError *error) {
//                                        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
//                                        expect(error.code).to.equal(BTMerchantIntegrationErrorUnauthorized);
//                                        [expectation fulfill];
//                                    }];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        it(@"noops for save card if the failure block is nil", ^{
//            BTClientCardcard *card = [[BTClientCardcard alloc] init];
//            card.number = @"4111111111111111";
//            card.expirationMonth = @"12";
//            card.expirationYear = @"2018";
//            card.shouldValidate = YES;
//            [testClient saveCardWithcard:card
//                                    success:nil
//                                    failure:nil];
//
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for potential async exceptions"];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//                [expectation fulfill];
//            });
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//    });
//

//
//    describe(@"3D Secure", ^{
//        __block BTClient *testThreeDSecureClient;
//
//        beforeEach(^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client"];
//            NSDictionary *configuration = @{ BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
//                                             BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
//                                             BTClientTestConfigurationKeyMerchantAccountIdentifier: @"three_d_secure_merchant_account",
//                                             BTClientTestConfigurationKeyClientTokenVersion: @2 };
//            [BTClient testClientWithConfiguration:configuration
//                                            async:asyncClient completion:^(BTClient *testClient) {
//                                                testThreeDSecureClient = testClient;
//                                                [expectation fulfill];
//                                            }];
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//
//        describe(@"of an eligible Visa", ^{
//            __block NSString *nonce;
//
//            beforeEach(^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
//                BTClientCardcard *r = [[BTClientCardcard alloc] init];
//                r.number = @"4010000000000018";
//                r.expirationDate = @"12/2015";
//
//                [testThreeDSecureClient saveCardWithcard:r
//                                                    success:^(BTCardPaymentMethod *card) {
//                                                        nonce = card.nonce;
//                                                        [expectation fulfill];
//                                                    }
//                                                    failure:nil];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//
//            it(@"performs lookup to give a new nonce and other parameters that allow you to kick off a web-based auth flow", ^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Perform lookup"];
//                [testThreeDSecureClient
//                 lookupNonceForThreeDSecure:nonce
//                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
//                 success:^(BTThreeDSecureLookupResult *threeDSecureLookupResult) {
//                     expect(threeDSecureLookupResult.requiresUserAuthentication).to.beTruthy();
//                     expect(threeDSecureLookupResult.MD).to.beKindOf([NSString class]);
//                     expect(threeDSecureLookupResult.acsURL).to.equal([NSURL URLWithString:@"https://testcustomer34.cardinalcommerce.com/V3DSStart?osb=visa-3&VAA=B"]);
//                     expect([threeDSecureLookupResult.termURL absoluteString]).to.match(@"/merchants/integration_merchant_id/client_api/v1/payment_methods/[a-fA-F0-9-]+/three_d_secure/authenticate\?.*");
//                     expect(threeDSecureLookupResult.PAReq).to.beKindOf([NSString class]);
//
//                     [expectation fulfill];
//                 }
//                 failure:nil];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//        });
//
//        describe(@"of an unenrolled Visa", ^{
//            __block NSString *nonce;
//
//            beforeEach(^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
//                BTClientCardcard *r = [[BTClientCardcard alloc] init];
//                r.number = @"4000000000000051";
//                r.expirationDate = @"01/2020";
//
//                [testThreeDSecureClient saveCardWithcard:r
//                                                    success:^(BTCardPaymentMethod *card) {
//                                                        nonce = card.nonce;
//                                                        [expectation fulfill];
//                                                    }
//                                                    failure:nil];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//
//            it(@"succeeds without further intervention, since the liability shifts without authentication ", ^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Perform lookup"];
//                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
//                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
//                                                           success:^(BTThreeDSecureLookupResult *threeDSecureLookup) {
//                                                               expect(threeDSecureLookup.requiresUserAuthentication).to.beFalsy();
//                                                               expect(threeDSecureLookup.card.nonce).to.beANonce();
//                                                               expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShifted"] boolValue]).to.beTruthy();
//                                                               expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShiftPossible"] boolValue]).to.beTruthy();
//                                                               [expectation fulfill];
//                                                           } failure:nil];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//        });
//
//        describe(@"of an enrolled, issuer unavailable card", ^{
//            __block NSString *nonce;
//
//            beforeEach(^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
//                BTClientCardcard *r = [[BTClientCardcard alloc] init];
//                r.number = @"4000000000000069";
//                r.expirationDate = @"01/2020";
//
//                [testThreeDSecureClient saveCardWithcard:r
//                                                    success:^(BTCardPaymentMethod *card) {
//                                                        nonce = card.nonce;
//                                                        [expectation fulfill];
//                                                    }
//                                                    failure:nil];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//
//            it(@"performs lookup to give a new nonce without other parameters since no web-based auth flow is required", ^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Perform lookup"];
//                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
//                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
//                                                           success:^(BTThreeDSecureLookupResult *threeDSecureLookup) {
//                                                               expect(threeDSecureLookup.requiresUserAuthentication).to.beFalsy();
//                                                               expect(threeDSecureLookup.card.nonce).to.beANonce();
//                                                               expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShifted"] boolValue]).to.beFalsy();
//                                                               expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShiftPossible"] boolValue]).to.beFalsy();
//                                                               [expectation fulfill];
//                                                           } failure:nil];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//        });
//
//        describe(@"of an ineligible card type", ^{
//            __block NSString *nonce;
//
//            beforeEach(^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
//                BTClientCardcard *r = [[BTClientCardcard alloc] init];
//                r.number = @"6011111111111117";
//                r.expirationDate = @"01/2020";
//
//                [testThreeDSecureClient saveCardWithcard:r
//                                                    success:^(BTCardPaymentMethod *card) {
//                                                        nonce = card.nonce;
//                                                        [expectation fulfill];
//                                                    }
//                                                    failure:nil];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//
//            it(@"succeeds without a liability shift", ^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Perform lookup"];
//                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
//                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
//                                                           success:^(BTThreeDSecureLookupResult *threeDSecureLookup) {
//                                                               expect(threeDSecureLookup.requiresUserAuthentication).to.beFalsy();
//                                                               expect(threeDSecureLookup.card.nonce).to.beANonce();
//                                                               expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShifted"] boolValue]).to.beFalsy();
//                                                               expect([threeDSecureLookup.card.threeDSecureInfoDictionary[@"liabilityShiftPossible"] boolValue]).to.beFalsy();
//                                                               [expectation fulfill];
//                                                           }
//                                                           failure:nil];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//
//            describe(@"of an invalid card nonce", ^{
//                __block NSString *nonce;
//
//                beforeEach(^{
//                    XCTestExpectation *expectation = [self expectationWithDescription:@"Save card"];
//                    BTClientCardcard *r = [[BTClientCardcard alloc] init];
//                    r.number = @"not a card number";
//                    r.expirationDate = @"12/2020";
//
//                    [testThreeDSecureClient saveCardWithcard:r
//                                                        success:^(BTCardPaymentMethod *card) {
//                                                            nonce = card.nonce;
//                                                            [expectation fulfill];
//                                                        }
//                                                        failure:nil];
//                    [self waitForExpectationsWithTimeout:10 handler:nil];
//                });
//
//                it(@"fails to perform a lookup", ^{
//                    XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to perform lookup"];
//                    [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
//                                                     transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
//                                                               success:nil
//                                                               failure:^(NSError *error) {
//                                                                   expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
//                                                                   expect(error.code).to.equal(BTCustomerInputErrorInvalid);
//                                                                   expect(error.localizedDescription).to.contain(@"Credit card number is invalid");
//                                                                   expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.equal(@{ @"message": @"Credit card number is invalid" });
//                                                                   expect(error.userInfo[BTThreeDSecureInfoKey]).to.equal(@{ @"liabilityShiftPossible": @0, @"liabilityShifted": @0, });
//                                                                   [expectation fulfill];
//                                                               }];
//                    [self waitForExpectationsWithTimeout:10 handler:nil];
//                });
//            });
//        });
//
//        describe(@"of a non-card nonce", ^{
//            __block NSString *nonce;
//            __block BTClient *testPayPalClient;
//
//            beforeEach(^{
//                XCTestExpectation *clientExpectation = [self expectationWithDescription:@"Fetch client that supports PayPal"];
//                NSDictionary *configuration = @{ BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
//                                                 BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
//                                                 BTClientTestConfigurationKeyMerchantAccountIdentifier: @"sandbox_credit_card",
//                                                 BTClientTestConfigurationKeyClientTokenVersion: @2 };
//                [BTClient testClientWithConfiguration:configuration
//                                                async:asyncClient completion:^(BTClient *testClient) {
//                                                    testPayPalClient = testClient;
//                                                    [clientExpectation fulfill];
//                                                }];
//                [self waitForExpectationsWithTimeout:5 handler:nil];
//
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Get PayPal nonce"];
//                [testPayPalClient savePaypalPaymentMethodWithAuthCode:@"fake-paypal-auth-code"
//                                             applicationCorrelationID:nil
//                                                              success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
//                                                                  nonce = paypalPaymentMethod.nonce;
//                                                                  [expectation fulfill];
//                                                              } failure:^(NSError *error) {
//                                                                  XCTFail(@"Unexpected error: %@", error);
//                                                              }];
//                [self waitForExpectationsWithTimeout:5 handler:nil];
//            });
//
//            it(@"fails to perform a lookup", ^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to perform lookup"];
//                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
//                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
//                                                           success:nil
//                                                           failure:^(NSError *error) {
//                                                               expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
//                                                               expect(error.code).to.equal(BTCustomerInputErrorInvalid);
//                                                               expect(error.localizedDescription).to.contain(@"Cannot 3D Secure a non-credit card payment instrument");
//                                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.beKindOf([NSDictionary class]);
//                                                               [expectation fulfill];
//                                                           }];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//        });
//
//        describe(@"unregistered 3DS merchant", ^{
//            __block NSString *nonce;
//
//            beforeEach(^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client and save card"];
//                [BTClient testClientWithConfiguration:@{
//                                                        BTClientTestConfigurationKeyMerchantIdentifier: @"altpay_merchant",
//                                                        BTClientTestConfigurationKeyPublicKey: @"altpay_merchant_public_key",
//                                                        BTClientTestConfigurationKeyClientTokenVersion: @2
//                                                        } async:asyncClient completion:^(BTClient *testClient) {
//                                                            testThreeDSecureClient = testClient;
//                                                            BTClientCardcard *r = [[BTClientCardcard alloc] init];
//                                                            r.number = @"4000000000000051";
//                                                            r.expirationDate = @"01/2020";
//
//                                                            [testThreeDSecureClient saveCardWithcard:r
//                                                                                                success:^(BTCardPaymentMethod *card) {
//                                                                                                    nonce = card.nonce;
//                                                                                                    [expectation fulfill];
//                                                                                                }
//                                                                                                failure:nil];
//                                                        }];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//
//            it(@"fails to lookup", ^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to perform lookup"];
//                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
//                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
//                                                           success:nil
//                                                           failure:^(NSError *error) {
//                                                               expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
//                                                               expect(error.code).to.equal(BTCustomerInputErrorInvalid);
//                                                               expect(error.localizedDescription).to.contain(@"Merchant account not 3D Secure enabled");
//                                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.beKindOf([NSDictionary class]);
//                                                               [expectation fulfill];
//                                                           }];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//        });
//
//        describe(@"unregistered 3DS merchant accounts", ^{
//            __block NSString *nonce;
//
//            beforeEach(^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch client and save card"];
//                [BTClient testClientWithConfiguration:@{
//                                                        BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
//                                                        BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
//                                                        BTClientTestConfigurationKeyClientTokenVersion: @2
//                                                        } async:asyncClient completion:^(BTClient *testClient) {
//                                                            testThreeDSecureClient = testClient;
//                                                            BTClientCardcard *r = [[BTClientCardcard alloc] init];
//                                                            r.number = @"4000000000000051";
//                                                            r.expirationDate = @"01/2020";
//
//                                                            [testThreeDSecureClient saveCardWithcard:r
//                                                                                                success:^(BTCardPaymentMethod *card) {
//                                                                                                    nonce = card.nonce;
//                                                                                                    [expectation fulfill];
//                                                                                                }
//                                                                                                failure:nil];
//                                                        }];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//
//            it(@"fails to lookup", ^{
//                XCTestExpectation *expectation = [self expectationWithDescription:@"Fail to lookup"];
//                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
//                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
//                                                           success:nil
//                                                           failure:^(NSError *error) {
//                                                               expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
//                                                               expect(error.code).to.equal(BTCustomerInputErrorInvalid);
//                                                               expect(error.localizedDescription).to.contain(@"Merchant account not 3D Secure enabled");
//                                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.beKindOf([NSDictionary class]);
//                                                               [expectation fulfill];
//                                                           }];
//                [self waitForExpectationsWithTimeout:10 handler:nil];
//            });
//        });
//    });
//
//    describe(@"createPayPalPaymentResourceWithAmount:", ^{
//        it(@"creates a single payments resource for use in checkout", ^{
//            XCTestExpectation *expectation = [self expectationWithDescription:@""];
//            NSString *cancelUrl = @"https://example.com/cancel";
//            NSString *successUrl = @"https://example.com/redirect";
//
//            [testClient createPayPalPaymentResourceWithAmount:[NSDecimalNumber decimalNumberWithString:@"1.23"] currencyCode:@"USD" redirectUri:successUrl cancelUri:cancelUrl clientMetadataID:@"fake-metadata-id" success:^(BTClientPayPalPaymentResource *paymentResource) {
//                expect(paymentResource.redirectURL).to.beKindOf([NSURL class]);
//                expect([[paymentResource.redirectURL absoluteString] length]).to.beGreaterThan(0);
//                [expectation fulfill];
//            } failure:^(NSError *error) {
//                expect(error).to.beNil();
//            }];
//
//
//            [self waitForExpectationsWithTimeout:10 handler:nil];
//        });
//    });
//});
//
//SharedExamplesEnd
//
//SpecBegin(DeprecatedBTClient)
//
//describe(@"shared initialization behavior", ^{
//    NSDictionary* data = @{@"asyncClient": @NO};
//    itShouldBehaveLike(@"a BTClient", data);
//});
//
//SpecEnd
//
//SpecBegin(AsyncBTClient)
//
//describe(@"shared initialization behavior", ^{
//    NSDictionary* data = @{@"asyncClient": @YES};
//    itShouldBehaveLike(@"a BTClient", data);
//});
//
//SpecEnd
//
