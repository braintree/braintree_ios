#import "BTClient_Internal.h"
#import "BTClient+Testing.h"

void wait_for_potential_async_exceptions(void (^done)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        done();
    });
}

SpecBegin(BTClient_Integration)

__block BTClient *testClient;

beforeEach(^{
    waitUntil(^(DoneCallback done){
        [BTClient testClientWithConfiguration:@{
                                                BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                BTClientTestConfigurationKeyCustomer:@YES,
                                                BTClientTestConfigurationKeyClientTokenVersion: @2
                                                } completion:^(BTClient *client) {
                                                    testClient = client;
                                                    done();
                                                }];
    });
});

describe(@"challenges", ^{
    it(@"returns a set of Gateway specified challenge questions for the merchant", ^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                    BTClientTestConfigurationKeyCustomer:@YES }
                                       completion:^(BTClient *client) {
                                           expect(client.challenges).to.haveCountOf(0);
                                           done();
                                       }];
        });
    });
    it(@"returns a set of Gateway specified challenge questions for the merchant", ^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier:@"client_api_cvv_verification_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey:@"client_api_cvv_verification_public_key",
                                                    BTClientTestConfigurationKeyCustomer:@YES }
                                       completion:^(BTClient *client) {
                                           expect(client.challenges).to.haveCountOf(1);
                                           expect(client.challenges).to.contain(@"cvv");
                                           done();
                                       }];
        });
    });
    it(@"returns a set of Gateway specified challenge questions for the merchant", ^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier:@"client_api_postal_code_verification_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey:@"client_api_postal_code_verification_public_key",
                                                    BTClientTestConfigurationKeyCustomer:@YES }
                                       completion:^(BTClient *client) {
                                           expect(client.challenges).to.haveCountOf(1);
                                           expect(client.challenges).to.contain(@"postal_code");
                                           done();
                                       }];
        });
    });
    it(@"returns a set of Gateway specified challenge questions for the merchant", ^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier:@"client_api_cvv_and_postal_code_verification_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey:@"client_api_cvv_and_postal_code_verification_public_key",
                                                    BTClientTestConfigurationKeyCustomer:@YES }
                                       completion:^(BTClient *client) {
                                           expect(client.challenges).to.haveCountOf(2);
                                           expect(client.challenges).to.contain(@"postal_code");
                                           expect(client.challenges).to.contain(@"cvv");
                                           done();
                                       }];
        });
    });
});

describe(@"save card", ^{
    describe(@"with validation disabled", ^{
        it(@"creates an unlocked card with a nonce using an invalid card", ^{
            waitUntil(^(DoneCallback done){
                [testClient saveCardWithNumber:@"INVALID_CARD"
                               expirationMonth:@"XX"
                                expirationYear:@"YYYY"
                                           cvv:nil
                                    postalCode:nil
                                      validate:NO
                                       success:^(BTPaymentMethod *card) {
                                           expect(card.nonce).to.beANonce();
                                           done();
                                       } failure:nil];
            });
        });

        it(@"creates an unlocked card with a nonce using a valid card", ^{
            waitUntil(^(DoneCallback done){
                [testClient saveCardWithNumber:@"4111111111111111"
                               expirationMonth:@"12"
                                expirationYear:@"2018"
                                           cvv:nil
                                    postalCode:nil
                                      validate:NO
                                       success:^(BTPaymentMethod *card) {
                                           expect(card.nonce).to.beANonce();
                                           done();
                                       } failure:nil];
            });
        });
    });

    describe(@"with validation enabled", ^{
        it(@"creates an unlocked card with a nonce", ^{
            waitUntil(^(DoneCallback done){
                [testClient saveCardWithNumber:@"4111111111111111"
                               expirationMonth:@"12"
                                expirationYear:@"2018"
                                           cvv:nil
                                    postalCode:nil
                                      validate:YES
                                       success:^(BTPaymentMethod *card) {
                                           expect(card.nonce).to.beANonce();
                                           done();
                                       } failure:nil];
            });
        });

        it(@"populates card details based on the server-side response", ^{
            waitUntil(^(DoneCallback done){
                [testClient saveCardWithNumber:@"5555555555554444"
                               expirationMonth:@"12"
                                expirationYear:@"2018"
                                           cvv:nil
                                    postalCode:nil
                                      validate:YES
                                       success:^(BTCardPaymentMethod *card) {
                                           expect(card.type).to.equal(BTCardTypeMasterCard);
                                           expect(card.lastTwo).to.equal(@"44");
                                           expect(card.description).to.equal(@"ending in 44");
                                           done();
                                       } failure:nil];
            });
        });

        it(@"fails when the provided card number is not valid", ^{
            waitUntil(^(DoneCallback done){
                [testClient saveCardWithNumber:@"4111111111111112"
                               expirationMonth:@"12"
                                expirationYear:@"2018"
                                           cvv:nil
                                    postalCode:nil
                                      validate:YES
                                       success:nil
                                       failure:^(NSError *error) {
                                           expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                           expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                           done();
                                       }];
            });
        });

        it(@"fails and provides all braintree validation errors when user input is invalid", ^{
            waitUntil(^(DoneCallback done){
                [testClient saveCardWithNumber:@"4111111111111112"
                               expirationMonth:@"82"
                                expirationYear:@"2"
                                           cvv:nil
                                    postalCode:nil
                                      validate:YES
                                       success:nil
                                       failure:^(NSError *error) {
                                           expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).toNot.beNil();

                                           NSDictionary *validationErrors = error.userInfo[BTCustomerInputBraintreeValidationErrorsKey];
                                           NSArray *fieldErrors = validationErrors[@"fieldErrors"];
                                           NSDictionary *creditCardFieldError = fieldErrors[0];

                                           expect(fieldErrors).to.haveCountOf(1);

                                           expect(creditCardFieldError[@"field"]).to.equal(@"creditCard");
                                           expect(creditCardFieldError[@"fieldErrors"]).to.haveCountOf(3);

                                           expect(creditCardFieldError[@"fieldErrors"]).to.contain((@{@"field": @"expirationYear",
                                                                                                      @"message": @"Expiration year is invalid",
                                                                                                      @"code": @"81713"}));
                                           expect(creditCardFieldError[@"fieldErrors"]).to.contain((@{@"field": @"expirationMonth",
                                                                                                      @"message": @"Expiration month is invalid",
                                                                                                      @"code": @"81712"}));
                                           expect(creditCardFieldError[@"fieldErrors"]).to.contain((@{@"field": @"number",
                                                                                                      @"message": @"Credit card number is invalid",
                                                                                                      @"code": @"81715"}));
                                           done();
                                       }];
            });
        });

        it(@"saves a transactable credit card nonce", ^{
            waitUntil(^(DoneCallback done){
                [testClient saveCardWithNumber:@"4111111111111111"
                               expirationMonth:@"12"
                                expirationYear:@"2018"
                                           cvv:nil
                                    postalCode:nil
                                      validate:YES
                                       success:^(BTPaymentMethod *card) {
                                           [testClient fetchNonceInfo:card.nonce
                                                              success:^(NSDictionary *nonceInfo) {
                                                                  expect(nonceInfo[@"isLocked"]).to.beFalsy();
                                                                  expect(nonceInfo[@"isConsumed"]).to.beFalsy();
                                                                  done();
                                                              }
                                                              failure:nil];
                                       } failure:nil];
            });
        });

        describe(@"for a merchant with payment method verification enabled", ^{
            __block BTClient *cvvAndZipClient;
            beforeEach(^{
                waitUntil(^(DoneCallback done){
                    [BTClient testClientWithConfiguration:@{
                                                            BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_cvv_and_postal_code_verification_merchant_id",
                                                            BTClientTestConfigurationKeyPublicKey: @"client_api_cvv_and_postal_code_verification_public_key",
                                                            BTClientTestConfigurationKeyCustomer: @YES }
                                               completion:^(BTClient *client) {
                                                   cvvAndZipClient = client;
                                                   done();
                                               }];
                });
            });

            it(@"saves a card when the challenges are provided", ^{
                waitUntil(^(DoneCallback done){
                    [cvvAndZipClient saveCardWithNumber:@"4111111111111111"
                                        expirationMonth:@"12"
                                         expirationYear:@"38"
                                                    cvv:@"100"
                                             postalCode:@"15213"
                                               validate:YES
                                                success:^(BTCardPaymentMethod *card) {
                                                    expect(card.nonce).to.beANonce();
                                                    done();
                                                } failure:nil];
                });
            });

            it(@"fails to save a card when a cvv response is incorrect", ^{
                waitUntil(^(DoneCallback done){
                    [BTClient testClientWithConfiguration:@{
                                                            BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_cvv_verification_merchant_id",
                                                            BTClientTestConfigurationKeyPublicKey: @"client_api_cvv_verification_public_key",
                                                            BTClientTestConfigurationKeyCustomer: @YES }
                                               completion:^(BTClient *cvvClient) {

                                                   [cvvClient saveCardWithNumber:@"4111111111111111"
                                                                 expirationMonth:@"12"
                                                                  expirationYear:@"38"
                                                                             cvv:@"200"
                                                                      postalCode:@"15213"
                                                                        validate:YES
                                                                         success:nil
                                                                         failure:^(NSError *error) {
                                                                             expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                                             expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                                             expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(1);
                                                                             expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"cvv");
                                                                             done();
                                                                         }];
                                               }];
                });
            });

            it(@"fails to save a card when a postal code response is incorrect", ^{
                waitUntil(^(DoneCallback done){
                    [BTClient testClientWithConfiguration:@{
                                                            BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_postal_code_verification_merchant_id",
                                                            BTClientTestConfigurationKeyPublicKey: @"client_api_postal_code_verification_public_key",
                                                            BTClientTestConfigurationKeyCustomer: @YES }
                                               completion:^(BTClient *zipClient) {
                                                   [zipClient saveCardWithNumber:@"4111111111111111"
                                                                 expirationMonth:@"12"
                                                                  expirationYear:@"38"
                                                                             cvv:@"100"
                                                                      postalCode:@"20000"
                                                                        validate:YES
                                                                         success:nil
                                                                         failure:^(NSError *error) {
                                                                             expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                                             expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                                             expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(1);
                                                                             expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"postalCode");

                                                                             done();
                                                                         }];
                                               }];
                });
            });

            it(@"fails to save a card when cvv and postal code responses are both incorrect", ^{
                waitUntil(^(DoneCallback done){
                    [cvvAndZipClient saveCardWithNumber:@"4111111111111111"
                                        expirationMonth:@"12"
                                         expirationYear:@"38"
                                                    cvv:@"200"
                                             postalCode:@"20000"
                                               validate:YES
                                                success:nil
                                                failure:^(NSError *error) {
                                                    expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                    expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                    expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"]).to.haveCountOf(2);
                                                    expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][0][@"field"]).to.equal(@"cvv");
                                                    expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"fieldErrors"][0][@"fieldErrors"][1][@"fieldErrors"][0][@"field"]).to.equal(@"postalCode");
                                                    done();
                                                }];
                });
            });
        });
    });
});

describe(@"list payment methods", ^{
    __block BTPaymentMethod *card1, *card2;

    beforeEach(^{
        waitUntil(^(DoneCallback done){
            [testClient saveCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate:YES
                                   success:^(BTPaymentMethod *card) {
                                       card1 = card;
                                       [testClient saveCardWithNumber:@"5555555555554444"
                                                      expirationMonth:@"3"
                                                       expirationYear:@"2016"
                                                                  cvv:nil
                                                           postalCode:nil
                                                             validate:YES
                                                              success:^(BTPaymentMethod *card) {
                                                                  card2 = card;
                                                                  done();
                                                              } failure:nil];
                                   } failure:nil];
        });
    });

    it(@"fetches a list of payment methods", ^{
        waitUntil(^(DoneCallback done){
            [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                expect(paymentMethods).to.haveCountOf(2);
                [paymentMethods enumerateObjectsUsingBlock:^(BTPaymentMethod *card, NSUInteger idx, BOOL *stop) {
                    expect(card.nonce).to.beANonce();
                }];
                done();
            } failure:nil];
        });
    });

    it(@"saves two cards and returns them in subsequent calls to list cards", ^{
        waitUntil(^(DoneCallback done){
            [testClient saveCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate:YES
                                   success:^(BTPaymentMethod *card1){
                                       [testClient saveCardWithNumber:@"5555555555554444"
                                                      expirationMonth:@"3"
                                                       expirationYear:@"2016"
                                                                  cvv:nil
                                                           postalCode:nil
                                                             validate:YES
                                                              success:^(BTPaymentMethod *card2){
                                                                  [testClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                                                                      expect(paymentMethods).to.haveCountOf(2);

                                                                      done();
                                                                  } failure:nil];
                                                              } failure:nil];
                                   } failure:nil];
        });
    });
});

describe(@"show payment method", ^{
    it(@"gets a full representation of a payment method based on a nonce", ^{
        waitUntil(^(DoneCallback done){
            [testClient saveCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:@"100"
                                postalCode:nil
                                  validate:YES
                                   success:^(BTCardPaymentMethod *card){
                                       NSString *aNonce = card.nonce;
                                       [testClient fetchPaymentMethodWithNonce:aNonce
                                                                       success:^(BTPaymentMethod *paymentMethod) {
                                                                           expect(paymentMethod).to.beKindOf([BTCardPaymentMethod class]);

                                                                           BTCardPaymentMethod *cardPaymentMethod = (BTCardPaymentMethod *)paymentMethod;
                                                                           expect(cardPaymentMethod.lastTwo).to.equal(@"11");
                                                                           expect(cardPaymentMethod.type).to.equal(BTCardTypeVisa);
                                                                           done();
                                                                       }
                                                                       failure:nil];
                                   }
                                   failure:nil];
        });
    });
});

describe(@"get nonce", ^{
    it(@"gets an info dictionary about a nonce", ^{
        waitUntil(^(DoneCallback done) {
            [testClient saveCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate:YES
                                   success:^(BTPaymentMethod *card){
                                       NSString *aNonce = card.nonce;
                                       [testClient fetchNonceInfo:aNonce success:^(NSDictionary *nonceInfo) {
                                           expect(nonceInfo).to.beKindOf([NSDictionary class]);
                                           done();
                                       }
                                                          failure:nil];
                                   } failure:nil];
        });
    });

    it(@"fails to get information about a non-existent nonce", ^{
        waitUntil(^(DoneCallback done){
            [testClient fetchNonceInfo:@"non-existent-nonce" success:nil failure:^(NSError *error) {
                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTMerchantIntegrationErrorNonceNotFound);
                done();
            }];
        });
    });

    it(@"fails to get information about a poorly formatted nonce", ^{
        waitUntil(^(DoneCallback done){
            [testClient fetchNonceInfo:@"?strange/nonce&private_key=foo&stuff%20more" success:nil failure:^(NSError *error) {
                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTMerchantIntegrationErrorNonceNotFound);
                done();
            }];
        });
    });
});

describe(@"clients with Apple Pay activated", ^{
    
    if ([PKPayment class]) {
        it(@"can save an Apple Pay payment based on a PKPayment if Apple Pay is supported", ^{

            waitUntil(^(DoneCallback done){

                id payment = [OCMockObject partialMockForObject:[[PKPayment alloc] init]];
                id paymentToken = [OCMockObject partialMockForObject:[[PKPaymentToken alloc] init]];

                [[[payment stub] andReturn:paymentToken] token];
                [[[paymentToken stub] andReturn:[NSData data]] paymentData];
                [[[paymentToken stub] andReturn:@"an amex 12345"] paymentInstrumentName];
                [[[paymentToken stub] andReturn:PKPaymentNetworkAmex] paymentNetwork];
                [[[paymentToken stub] andReturn:@"transaction-identifier"] transactionIdentifier];

                BTClientApplePayRequest *request = [[BTClientApplePayRequest alloc] initWithApplePayPayment:payment];
                [testClient saveApplePayPayment:request success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                    expect(applePayPaymentMethod.nonce).to.beANonce();
                    done();
                } failure:nil];
            });
        });
    }
});


describe(@"clients with PayPal activated", ^{
    __block BTClient *testClient;
    beforeEach(^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
                                                     BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                                     BTClientTestConfigurationKeyCustomer: @YES }
                                       completion:^(BTClient *client) {
                                           testClient = client;
                                           done();
                                       }];
        });
    });

    it(@"can save a PayPal payment method based on an auth code", ^{
        waitUntil(^(DoneCallback done){
            [testClient savePaypalPaymentMethodWithAuthCode:@"testAuthCode"
                                   applicationCorrelationID:@"testCorrelationId"
                                                    success:^(BTPayPalPaymentMethod *payPalPaymentMethod){
                                                        expect(payPalPaymentMethod.nonce).to.beANonce();
                                                        expect(payPalPaymentMethod.email).to.beKindOf([NSString class]);
                                                        done();
                                                    } failure:nil];
        });
    });

    it(@"can save a PayPal payment method based on an auth code without a correlation id", ^{
        waitUntil(^(DoneCallback done){
            [testClient savePaypalPaymentMethodWithAuthCode:@"testAuthCode"
                                   applicationCorrelationID:nil
                                                    success:^(BTPayPalPaymentMethod *payPalPaymentMethod){
                                                        expect(payPalPaymentMethod.nonce).to.beANonce();
                                                        expect(payPalPaymentMethod.email).to.beKindOf([NSString class]);
                                                        done();
                                                    } failure:nil];
        });
    });
});

describe(@"a client initialized with a revoked authorization fingerprint", ^{
    __block BTClient *testClient;
    beforeEach(^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{ BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                                     BTClientTestConfigurationKeyCustomer: @YES,
                                                     BTClientTestConfigurationKeyRevoked: @YES }
                                       completion:^(BTClient *client) {
                                           testClient = client;
                                           done();
                                       }];
        });
    });

    it(@"invokes the failure block for list payment methods", ^{
        waitUntil(^(DoneCallback done){
            [testClient fetchPaymentMethodsWithSuccess:nil failure:^(NSError *error) {
                expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                expect(error.code).to.equal(BTMerchantIntegrationErrorUnauthorized);
                done();
            }];
        });
    });

    it(@"noops for list cards if the failure block is nil", ^{
        waitUntil(^(DoneCallback done){
            [testClient fetchPaymentMethodsWithSuccess:nil failure:nil];

            wait_for_potential_async_exceptions(done);
        });
    });

    it(@"invokes the failure block for save card", ^{
        waitUntil(^(DoneCallback done){
            [testClient saveCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate: NO
                                   success:nil
                                   failure:^(NSError *error) {
                                       expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                       expect(error.code).to.equal(BTMerchantIntegrationErrorUnauthorized);
                                       done();
                                   }];
        });
    });

    it(@"noops for save card if the failure block is nil", ^{
        waitUntil(^(DoneCallback done){
            [testClient saveCardWithNumber:@"4111111111111111"
                           expirationMonth:@"12"
                            expirationYear:@"2018"
                                       cvv:nil
                                postalCode:nil
                                  validate:YES
                                   success:nil
                                   failure:nil];

            wait_for_potential_async_exceptions(done);
        });
    });
});

describe(@"post analytics event", ^{
    it(@"sends an analytics event", ^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                    BTClientTestConfigurationKeyCustomer:@YES,
                                                    BTClientTestConfigurationKeyAnalytics:@{ BTClientTestConfigurationKeyURL: @"http://localhost:3000/merchants/integration_merchant_id/client_api/v1/analytics" },
                                                    BTClientTestConfigurationKeyClientTokenVersion: @2
                                                    } completion:^(BTClient *client) {
                                                        testClient = client;
                                                        NSString *event = @"hello world! 🐴";
                                                        [testClient postAnalyticsEvent:event
                                                                               success:^{
                                                                                   done();
                                                                               }
                                                                               failure:nil];
                                                    }];
        });
    });

    it(@"is successful but does not send the event when analytics URL is omitted from the client token", ^{
        waitUntil(^(DoneCallback done){
            [BTClient testClientWithConfiguration:@{
                                                    BTClientTestConfigurationKeyMerchantIdentifier:@"integration_merchant_id",
                                                    BTClientTestConfigurationKeyPublicKey:@"integration_public_key",
                                                    BTClientTestConfigurationKeyCustomer:@YES,
                                                    BTClientTestConfigurationKeyAnalytics: [NSNull null],
                                                    BTClientTestConfigurationKeyClientTokenVersion: @2
                                                    } completion:^(BTClient *client) {
                                                        NSString *event = @"hello world! 🐴";
                                                        [client postAnalyticsEvent:event
                                                                           success:^{
                                                                               done();
                                                                           }
                                                                           failure:nil];
                                                    }];
        });
    });
});

SpecEnd
