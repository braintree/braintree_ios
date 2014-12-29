#import "BTClient_Internal.h"
#import "BTClient+Testing.h"

@import AddressBook;

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

describe(@"save card with request", ^{
    describe(@"with validation disabled", ^{
        it(@"creates an unlocked card with a nonce using an invalid card", ^{
            waitUntil(^(DoneCallback done) {
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"INVALID_CARD";
                request.expirationMonth = @"XX";
                request.expirationYear = @"YYYY";
                [testClient saveCardWithRequest:request
                                        success:^(BTPaymentMethod *card) {
                                            expect(card.nonce).to.beANonce();
                                            done();
                                        } failure:nil];
            });
        });

        it(@"creates an unlocked card with a nonce using a valid card", ^{
            waitUntil(^(DoneCallback done) {
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2018";
                [testClient saveCardWithRequest:request
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
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2018";
                request.shouldValidate = YES;
                [testClient saveCardWithRequest:request
                                        success:^(BTPaymentMethod *card) {
                                            expect(card.nonce).to.beANonce();
                                            done();
                                        } failure:nil];
            });
        });

        it(@"populates card details based on the server-side response", ^{
            waitUntil(^(DoneCallback done) {
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"5555555555554444";
                request.expirationDate = @"12/2018";
                request.shouldValidate = YES;
                [testClient saveCardWithRequest:request
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
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111112";
                request.expirationMonth = @"12";
                request.expirationYear = @"2018";
                request.shouldValidate = YES;
                [testClient saveCardWithRequest:request
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
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111112";
                request.expirationMonth = @"82";
                request.expirationYear = @"2";
                request.shouldValidate = YES;

                [testClient saveCardWithRequest:request
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
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2018";
                request.shouldValidate = YES;

                [testClient saveCardWithRequest:request
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
                    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                    request.number = @"4111111111111111";
                    request.expirationMonth = @"12";
                    request.expirationYear = @"38";
                    request.cvv = @"100";
                    request.postalCode = @"15213";
                    request.shouldValidate = YES;
                    [cvvAndZipClient saveCardWithRequest:request
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
                                                   BTClientCardRequest *request = [[BTClientCardRequest alloc] init];

                                                   request.number = @"4111111111111111";
                                                   request.expirationMonth = @"12";
                                                   request.expirationYear = @"38";
                                                   request.cvv = @"200";
                                                   request.postalCode = @"15213";
                                                   request.shouldValidate = YES;
                                                   [cvvClient saveCardWithRequest:request
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
                    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                    [BTClient testClientWithConfiguration:@{
                                                            BTClientTestConfigurationKeyMerchantIdentifier: @"client_api_postal_code_verification_merchant_id",
                                                            BTClientTestConfigurationKeyPublicKey: @"client_api_postal_code_verification_public_key",
                                                            BTClientTestConfigurationKeyCustomer: @YES }
                                               completion:^(BTClient *zipClient) {
                                                   request.number = @"4111111111111111";
                                                   request.expirationMonth = @"12";
                                                   request.expirationYear = @"38";
                                                   request.cvv = @"100";
                                                   request.postalCode = @"20000";
                                                   request.shouldValidate = YES;
                                                   [zipClient saveCardWithRequest:request
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
                    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                    request.number = @"4111111111111111";
                    request.expirationMonth = @"12";
                    request.expirationYear = @"38";
                    request.cvv = @"200";
                    request.postalCode = @"20000";
                    request.shouldValidate = YES;
                    [cvvAndZipClient saveCardWithRequest:request
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


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
describe(@"save card (deprecated signature)", ^{
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
#pragma clang diagnostic pop

describe(@"list payment methods", ^{
    __block BTPaymentMethod *card1, *card2;

    beforeEach(^{
        waitUntil(^(DoneCallback done){
            BTClientCardRequest *request1 = [[BTClientCardRequest alloc] init];
            request1.number = @"4111111111111111";
            request1.expirationMonth = @"12";
            request1.expirationYear = @"2018";
            request1.shouldValidate = YES;

            [testClient saveCardWithRequest:request1
                                    success:^(BTPaymentMethod *card) {
                                        card1 = card;
                                        BTClientCardRequest *request2 = [[BTClientCardRequest alloc] init];

                                        request2.number = @"5555555555554444";
                                        request2.expirationDate = @"03/2016";
                                        request2.shouldValidate = YES;

                                        [testClient saveCardWithRequest:request2
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
            BTClientCardRequest *request1 = [[BTClientCardRequest alloc] init];
            request1.number = @"4111111111111111";
            request1.expirationMonth = @"12";
            request1.expirationYear = @"2018";
            request1.shouldValidate = YES;

            [testClient saveCardWithRequest:request1
                                    success:^(BTPaymentMethod *card1){
                                        BTClientCardRequest *request2 = [[BTClientCardRequest alloc] init];
                                        request2.number = @"5555555555554444";
                                        request2.expirationMonth = @"3";
                                        request2.expirationYear = @"2016";
                                        request2.shouldValidate = YES;

                                        [testClient saveCardWithRequest:request2
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
            BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
            request.number = @"4111111111111111";
            request.expirationMonth = @"12";
            request.expirationYear = @"2018";
            request.cvv = @"100";
            request.shouldValidate = YES;

            [testClient saveCardWithRequest:request
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
        waitUntil(^(DoneCallback done){
            BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
            request.number = @"4111111111111111";
            request.expirationMonth = @"12";
            request.expirationYear = @"2018";
            request.shouldValidate = YES;

            [testClient saveCardWithRequest:request
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
                [[[payment stub] andReturnValue:OCMOCK_VALUE(NULL)] shippingAddress];
                [[[payment stub] andReturnValue:OCMOCK_VALUE(NULL)] billingAddress];
                [[[payment stub] andReturn:nil] shippingMethod];
                [[[paymentToken stub] andReturn:[NSData data]] paymentData];
                [[[paymentToken stub] andReturn:@"an amex 12345"] paymentInstrumentName];
                [[[paymentToken stub] andReturn:PKPaymentNetworkAmex] paymentNetwork];
                [[[paymentToken stub] andReturn:@"transaction-identifier"] transactionIdentifier];

                [testClient saveApplePayPayment:payment success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                    expect(applePayPaymentMethod.nonce).to.beANonce();
                    expect(applePayPaymentMethod.shippingAddress).to.beNil();
                    expect(applePayPaymentMethod.billingAddress).to.beNil();
                    expect(applePayPaymentMethod.shippingMethod).to.beNil();
                    done();
                } failure:nil];
            });
        });

        it(@"can save an Apple Pay payment based on a PKPayment if Apple Pay is supported and return address information alongside the nonce", ^{
            waitUntil(^(DoneCallback done){
                id payment = [OCMockObject partialMockForObject:[[PKPayment alloc] init]];
                id paymentToken = [OCMockObject partialMockForObject:[[PKPaymentToken alloc] init]];

                ABRecordRef shippingAddress = ABPersonCreate();
                ABRecordRef billingAddress = ABPersonCreate();
                PKShippingMethod *shippingMethod = [PKShippingMethod summaryItemWithLabel:@"Shipping Method" amount:[NSDecimalNumber decimalNumberWithString:@"1"]];
                shippingMethod.detail = @"detail";
                shippingMethod.identifier = @"identifier";

                [[[payment stub] andReturn:paymentToken] token];
                [[[payment stub] andReturnValue:OCMOCK_VALUE((void *)shippingAddress)] shippingAddress];
                [[[payment stub] andReturnValue:OCMOCK_VALUE((void *)billingAddress)] billingAddress];
                [[[payment stub] andReturn:shippingMethod] shippingMethod];
                [[[paymentToken stub] andReturn:[NSData data]] paymentData];
                [[[paymentToken stub] andReturn:@"an amex 12345"] paymentInstrumentName];
                [[[paymentToken stub] andReturn:PKPaymentNetworkAmex] paymentNetwork];
                [[[paymentToken stub] andReturn:@"transaction-identifier"] transactionIdentifier];

                [testClient saveApplePayPayment:payment success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                    expect(applePayPaymentMethod.nonce).to.beANonce();
                    expect(applePayPaymentMethod.shippingAddress == shippingAddress).to.equal(YES);
                    expect(applePayPaymentMethod.billingAddress == billingAddress).to.equal(YES);
                    expect(applePayPaymentMethod.shippingMethod.label).to.equal(shippingMethod.label);
                    expect(applePayPaymentMethod.shippingMethod.amount).to.equal(shippingMethod.amount);
                    expect(applePayPaymentMethod.shippingMethod.detail).to.equal(shippingMethod.detail);
                    expect(applePayPaymentMethod.shippingMethod.identifier).to.equal(shippingMethod.identifier);
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
            BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
            request.number = @"4111111111111111";
            request.expirationMonth = @"12";
            request.expirationYear = @"2018";
            request.shouldValidate = NO;
            [testClient saveCardWithRequest:request
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
            BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
            request.number = @"4111111111111111";
            request.expirationMonth = @"12";
            request.expirationYear = @"2018";
            request.shouldValidate = YES;
            [testClient saveCardWithRequest:request
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

describe(@"3D Secure", ^{
    __block BTClient *testThreeDSecureClient;

    beforeEach(^{
        waitUntil(^(DoneCallback done) {
            NSDictionary *configuration = @{ BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
                                             BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                             BTClientTestConfigurationKeyMerchantAccountIdentifier: @"three_d_secure_merchant_account",
                                             BTClientTestConfigurationKeyClientTokenVersion: @2 };
            [BTClient testClientWithConfiguration:configuration
                                       completion:^(BTClient *testClient) {
                                           testThreeDSecureClient = testClient;
                                           done();
                                       }];
        });
    });

    describe(@"of an eligible Visa", ^{
        __block NSString *nonce;

        beforeEach(^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
                r.number = @"4010000000000018";
                r.expirationDate = @"12/2015";

                [testThreeDSecureClient saveCardWithRequest:r
                                                    success:^(BTCardPaymentMethod *card) {
                                                        nonce = card.nonce;
                                                        done();
                                                    }
                                                    failure:nil];
            });
        });

        it(@"performs lookup to give a new nonce and other parameters that allow you to kick off a web-based auth flow", ^{
            waitUntil(^(DoneCallback done) {
                [testThreeDSecureClient
                 lookupNonceForThreeDSecure:nonce
                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                 success:^(BTThreeDSecureLookupResult *threeDSecureLookupResult, BTCardPaymentMethod *card) {
                     expect(threeDSecureLookupResult.MD).to.beKindOf([NSString class]);
                     expect(threeDSecureLookupResult.acsURL).to.equal([NSURL URLWithString:@"https://testcustomer34.cardinalcommerce.com/V3DSStart?osb=visa-3&VAA=B"]);
                     expect([threeDSecureLookupResult.termURL absoluteString]).to.match(@"^http://.*:3000/merchants/integration_merchant_id/client_api/v1/payment_methods/[a-fA-F0-9-]+/three_d_secure/authenticate\?.*");
                     expect(threeDSecureLookupResult.PAReq).to.beKindOf([NSString class]);

                     done();
                 }
                 failure:nil];
            });
        });
    });

    describe(@"of an ineligible Visa", ^{
        __block NSString *nonce;

        beforeEach(^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
                r.number = @"4000000000000051";
                r.expirationDate = @"01/2020";

                [testThreeDSecureClient saveCardWithRequest:r
                                                    success:^(BTCardPaymentMethod *card) {
                                                        nonce = card.nonce;
                                                        done();
                                                    }
                                                    failure:nil];
            });
        });

        it(@"performs lookup to give a new nonce without other parameters since no web-based auth flow is required", ^{
            waitUntil(^(DoneCallback done) {
                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                           success:^(BTThreeDSecureLookupResult *threeDSecureLookupResult, BTCardPaymentMethod *card) {
                                                               expect(threeDSecureLookupResult).to.beNil();
                                                               expect(card).to.beKindOf([BTCardPaymentMethod class]);
                                                               expect(card.nonce).to.beANonce();
                                                               [testThreeDSecureClient fetchNonceThreeDSecureVerificationInfo:card.nonce
                                                                                                                      success:^(NSDictionary *nonceInfo) {
                                                                                                                          expect(nonceInfo[@"reportStatus"]).to.equal(@"lookup_unenrolled");
                                                                                                                          done();
                                                                                                                      } failure:nil];
                                                           }
                                                           failure:nil];
            });
        });
    });

    pending(@"of an ineligible card type", ^{
        __block NSString *nonce;

        beforeEach(^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
                r.number = @"6011111111111117";
                r.expirationDate = @"01/2020";

                [testThreeDSecureClient saveCardWithRequest:r
                                                    success:^(BTCardPaymentMethod *card) {
                                                        nonce = card.nonce;
                                                        done();
                                                    }
                                                    failure:nil];
            });
        });

        it(@"fails to perform lookup and returns an error", ^{
            waitUntil(^(DoneCallback done) {
                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                           success:^(BTThreeDSecureLookupResult *threeDSecureLookup, BTCardPaymentMethod *card) {
                                                               NSLog(@"%@ %@", threeDSecureLookup, card);
                                                           } failure:^(NSError *error) {
                                                               expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                               expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                               expect(error.localizedDescription).to.contain(@"Unsupported card type for 3D Secure");
                                                           }];
            });
        });
    });

    describe(@"of a non-card nonce", ^{
        __block NSString *nonce;

        beforeEach(^{
            waitUntil(^(DoneCallback done){
                [testThreeDSecureClient savePaypalPaymentMethodWithAuthCode:@"fake-paypal-auth-code"
                                                   applicationCorrelationID:nil
                                                                    success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                        nonce = paypalPaymentMethod.nonce;
                                                                        done();
                                                                    } failure:nil];
            });
        });

        it(@"fails to perform a lookup", ^{
            waitUntil(^(DoneCallback done) {
                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                           success:nil
                                                           failure:^(NSError *error) {
                                                               expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                               expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                               expect(error.localizedDescription).to.contain(@"Cannot 3D Secure a non-credit card payment instrument");
                                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.beKindOf([NSDictionary class]);
                                                               done();
                                                           }];
            });
        });
    });

    describe(@"unregistered 3DS merchant", ^{
        __block NSString *nonce;

        beforeEach(^{
            waitUntil(^(DoneCallback done) {
                [BTClient testClientWithConfiguration:@{
                                                        BTClientTestConfigurationKeyMerchantIdentifier: @"altpay_merchant",
                                                        BTClientTestConfigurationKeyPublicKey: @"altpay_merchant_public_key",
                                                        BTClientTestConfigurationKeyClientTokenVersion: @2
                                                        } completion:^(BTClient *testClient) {
                                                            testThreeDSecureClient = testClient;
                                                            BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
                                                            r.number = @"4000000000000051";
                                                            r.expirationDate = @"01/2020";

                                                            [testThreeDSecureClient saveCardWithRequest:r
                                                                                                success:^(BTCardPaymentMethod *card) {
                                                                                                    nonce = card.nonce;
                                                                                                    done();
                                                                                                }
                                                                                                failure:nil];
                                                        }];
            });
        });

        it(@"fails to lookup", ^{
            waitUntil(^(DoneCallback done) {
                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                           success:nil
                                                           failure:^(NSError *error) {
                                                               expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                               expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                               expect(error.localizedDescription).to.contain(@"Merchant not 3D Secure registered");
                                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.beKindOf([NSDictionary class]);
                                                               done();
                                                           }];
            });
        });
    });

    describe(@"unregistered 3DS merchant accounts", ^{
        __block NSString *nonce;

        beforeEach(^{
            waitUntil(^(DoneCallback done) {
                [BTClient testClientWithConfiguration:@{
                                                        BTClientTestConfigurationKeyMerchantIdentifier: @"integration_merchant_id",
                                                        BTClientTestConfigurationKeyPublicKey: @"integration_public_key",
                                                        BTClientTestConfigurationKeyClientTokenVersion: @2
                                                        } completion:^(BTClient *testClient) {
                                                            testThreeDSecureClient = testClient;
                                                            BTClientCardRequest *r = [[BTClientCardRequest alloc] init];
                                                            r.number = @"4000000000000051";
                                                            r.expirationDate = @"01/2020";

                                                            [testThreeDSecureClient saveCardWithRequest:r
                                                                                                success:^(BTCardPaymentMethod *card) {
                                                                                                    nonce = card.nonce;
                                                                                                    done();
                                                                                                }
                                                                                                failure:nil];
                                                        }];
            });
        });
        
        it(@"fails to lookup", ^{
            waitUntil(^(DoneCallback done) {
                [testThreeDSecureClient lookupNonceForThreeDSecure:nonce
                                                 transactionAmount:[NSDecimalNumber decimalNumberWithString:@"1"]
                                                           success:nil
                                                           failure:^(NSError *error) {
                                                               expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                                                               expect(error.code).to.equal(BTCustomerInputErrorInvalid);
                                                               expect(error.localizedDescription).to.contain(@"Merchant account not 3D Secure enabled");
                                                               expect(error.userInfo[BTCustomerInputBraintreeValidationErrorsKey]).to.beKindOf([NSDictionary class]);
                                                               done();
                                                           }];
            });
        });
    });
});

SpecEnd
