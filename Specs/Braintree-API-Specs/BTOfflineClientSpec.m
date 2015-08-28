#import <Foundation/Foundation.h>

#import "BTClient+Offline.h"

SpecBegin(BTClient_Offline)

describe(@"offline clients", ^{
    __block BTClient *offlineClient;
    
    beforeEach(^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSString *clientToken = [BTClient offlineTestClientTokenWithAdditionalParameters:nil];
        offlineClient = [[BTClient alloc] initWithClientToken:clientToken];
#pragma clang diagnostic pop
    });
    
    describe(@"initialization", ^{
        it(@"constructs a client when given the offline test client token", ^{
            expect(offlineClient).to.beKindOf([BTClient class]);
        });
    });
    
    describe(@"save card", ^{
        it(@"returns the newly saved card", ^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";
                [offlineClient saveCardWithRequest:request
                                           success:^(BTCardPaymentMethod *card) {
                                               expect(card.nonce).to.beANonce();
                                               expect(card.type).to.equal(BTCardTypeVisa);
                                               expect(card.lastTwo).to.equal(@"11");
                                               done();
                                           } failure:^(NSError *error){
                                               NSLog(@"error = %@", error);
                                           }];
            });
        });
        
        it(@"saves cards with the correct card types", ^{
            waitUntil(^(DoneCallback done){
                NSDictionary *cardTypesAndNumbers = @{ @"American Express": @"378282246310005",
                                                       @"Discover": @"6011111111111117",
                                                       @"MasterCard": @"5555555555554444",
                                                       @"Visa": @"4012000077777777",
                                                       @"JCB": @"3530111333300000",
                                                       @"Card": @"1234" };
                
                [cardTypesAndNumbers enumerateKeysAndObjectsUsingBlock:^(NSString *typeString, NSString *number, BOOL *stop) {
                    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                    request.number = number;
                    request.expirationMonth = @"12";
                    request.expirationYear = @"2038";
                    request.shouldValidate = YES;
                    [offlineClient saveCardWithRequest:request
                                               success:^(BTCardPaymentMethod *card) {
                                                   expect(card.typeString).to.equal(typeString);
                                                   done();
                                               }
                                               failure:nil];
                }];
            });
        });
        
        it(@"assigns new cards a nonce", ^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";
                request.shouldValidate = YES;
                
                [offlineClient saveCardWithRequest:request
                                           success:^(BTPaymentMethod *card) {
                                               expect(card.nonce).to.beANonce();
                                               
                                               done();
                                           } failure:nil];
            });
        });
        
        it(@"assigns each card a unique nonce", ^{
            waitUntil(^(DoneCallback done){
                NSMutableSet *uniqueNoncesReturned = [NSMutableSet set];
                
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";
                
                [offlineClient saveCardWithRequest:request
                                           success:^(BTPaymentMethod *card) {
                                               [uniqueNoncesReturned addObject:card.nonce];
                                               [offlineClient saveCardWithRequest:request
                                                                          success:^(BTPaymentMethod *card) {
                                                                              [uniqueNoncesReturned addObject:card.nonce];
                                                                              [offlineClient saveCardWithRequest:request
                                                                                                         success:^(BTPaymentMethod *card){
                                                                                                             [uniqueNoncesReturned addObject:card.nonce];
                                                                                                             
                                                                                                             expect(uniqueNoncesReturned).to.haveCountOf(3);
                                                                                                             
                                                                                                             done();
                                                                                                         }
                                                                                                         failure:nil];
                                                                          }
                                                                          failure:nil];
                                           }
                                           failure:nil];
            });
        });
        
        it(@"accepts a nil success block", ^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111111";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";
                request.shouldValidate = YES;
                
                [offlineClient saveCardWithRequest:request
                                           success:nil
                                           failure:nil];
                
                wait_for_potential_async_exceptions(done);
            });
        });
        
        it(@"accepts a nil failure block", ^{
            waitUntil(^(DoneCallback done){
                BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                request.number = @"4111111111111112";
                request.expirationMonth = @"12";
                request.expirationYear = @"2038";
                request.shouldValidate = YES;
                
                [offlineClient saveCardWithRequest:request
                                           success:nil
                                           failure:nil];
                
                wait_for_potential_async_exceptions(done);
            });
        });
        
        it(@"exhibits identical behavior when tokenizing a card", ^{
            
            BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
            request.number = @"4111111111111111";
            request.shouldValidate = NO;
            
            [offlineClient saveCardWithRequest:request
                                       success:^(BTCardPaymentMethod *card){
                                           
                                           expect(card.lastTwo).to.equal(@"11");
                                       }
                                       failure:nil];
        });
    });
    
    describe(@"save Paypal account", ^{
        it(@"returns the newly saved account", ^{
            waitUntil(^(DoneCallback done){
                [offlineClient savePaypalPaymentMethodWithAuthCode:@"authCode"
                                          applicationCorrelationID:@"correlationId"
                                                           success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                               expect(paypalPaymentMethod.nonce).to.beANonce();
                                                               expect(paypalPaymentMethod.email).to.endWith(@"@example.com");
                                                               done();
                                                           } failure:nil];
            });
        });
    });
    
    describe(@"save Apple Pay payments", ^{
        it(@"succeeds if payment is nil in mock mode", ^{
            waitUntil(^(DoneCallback done){
                [offlineClient saveApplePayPayment:[PKPayment new] success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                    if ([PKPayment class]) {
                        expect(applePayPaymentMethod.nonce).to.beANonce();
                        done();
                    }
                } failure:^(NSError *error) {
                    if (![PKPayment class]) {
                        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                        expect(error.code).to.equal(BTErrorUnsupported);
                        done();
                    }
                }];
            });
        });
        
        it(@"returns the newly saved account with SDK support for Apple Pay, or calls the failure block if there is no SDK support", ^{
            waitUntil(^(DoneCallback done){
                if ([PKPayment class] && [PKPaymentToken class]) {
                    id payment = [OCMockObject partialMockForObject:[[PKPayment alloc] init]];
                    id paymentToken = [OCMockObject partialMockForObject:[[PKPaymentToken alloc] init]];
                    
                    [[[payment stub] andReturn:paymentToken] token];
                    [[[paymentToken stub] andReturn:[NSData data]] paymentData];
                    
                    
                    [offlineClient saveApplePayPayment:payment
                                               success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                                                   expect(applePayPaymentMethod.nonce).to.beANonce();
                                                   done();
                                               } failure:nil];
                } else {
                    [offlineClient saveApplePayPayment:[PKPayment new] success:nil failure:^(NSError *error) {
                        expect(error.domain).to.equal(BTBraintreeAPIErrorDomain);
                        expect(error.code).to.equal(BTErrorUnsupported);
                        done();
                    }];
                }
            });
        });
    });
    
    describe(@"fetch payment methods", ^{
        it(@"initialy retrieves an empty list", ^{
            waitUntil(^(DoneCallback done){
                [offlineClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                    expect(paymentMethods).to.haveCountOf(0);
                    done();
                } failure:nil];
            });
        });
        
        describe(@"deprecated signature", ^{
            __block NSArray *paymentMethods;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            it(@"returns the newly saved card", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient saveCardWithNumber:@"4111111111111111"
                                      expirationMonth:@"12"
                                       expirationYear:@"2038"
                                                  cvv:nil
                                           postalCode:nil
                                             validate:YES
                                              success:^(BTCardPaymentMethod *card) {
                                                  expect(card.nonce).to.beANonce();
                                                  expect(card.type).to.equal(BTCardTypeVisa);
                                                  expect(card.lastTwo).to.equal(@"11");
                                                  done();
                                              } failure:nil];
                });
            });
            
            it(@"saves a cards with the correct card types", ^{
                waitUntil(^(DoneCallback done) {
                    NSDictionary *cardTypesAndNumbers = @{ @"American Express": @"378282246310005",
                                                           @"Discover": @"6011111111111117",
                                                           @"MasterCard": @"5555555555554444",
                                                           @"Visa": @"4012000077777777",
                                                           @"JCB": @"3530111333300000",
                                                           @"Card": @"1234" };
                    
                    [cardTypesAndNumbers enumerateKeysAndObjectsUsingBlock:^(NSString *typeString, NSString *number, BOOL *stop) {
                        [offlineClient saveCardWithNumber:number
                                          expirationMonth:@"12"
                                           expirationYear:@"2038"
                                                      cvv:nil
                                               postalCode:nil
                                                 validate:YES
                                                  success:^(BTCardPaymentMethod *card) {
                                                      expect(card.typeString).to.equal(typeString);
                                                      done();
                                                  }
                                                  failure:nil];
                    }];
                });
            });
            
            beforeEach(^{
                waitUntil(^(DoneCallback done){
                    [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                           postalCode:nil validate:YES success:^(BTPaymentMethod *card) {
                                               [offlineClient savePaypalPaymentMethodWithAuthCode:@"authCode"
                                                                         applicationCorrelationID:@""
                                                                                          success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                                              [offlineClient fetchPaymentMethodsWithSuccess:^(NSArray *fetchedPaymentMethods) {
                                                                                                  paymentMethods = fetchedPaymentMethods;
                                                                                                  done();
                                                                                              } failure:nil];
                                                                                          } failure:nil];
                                           } failure:nil];
                });
            });
            
            it(@"assigns new cards a nonce", ^{
                waitUntil(^(DoneCallback done){
                    [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                           postalCode:nil validate:YES success:^(BTPaymentMethod *card) {
                                               expect(card.nonce).to.beANonce();
                                               
                                               done();
                                           } failure:nil];
                });
            });
            
            it(@"assigns each card a unique nonce", ^{
                waitUntil(^(DoneCallback done) {
                    NSMutableSet *uniqueNoncesReturned = [NSMutableSet set];
                    
                    [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038"
                                                  cvv:nil
                                           postalCode:nil
                                             validate:YES success:^(BTPaymentMethod *card) {
                                                 [uniqueNoncesReturned addObject:card.nonce];
                                                 [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                                                        postalCode:nil validate:YES success:^(BTPaymentMethod *card) {
                                                                            [uniqueNoncesReturned addObject:card.nonce];
                                                                            [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                                                                                   postalCode:nil validate:YES success:^(BTPaymentMethod *card) {
                                                                                                       [uniqueNoncesReturned addObject:card.nonce];
                                                                                                       
                                                                                                       expect(uniqueNoncesReturned).to.haveCountOf(3);
                                                                                                       
                                                                                                       done();
                                                                                                   } failure:nil];
                                                                        } failure:nil];
                                             } failure:nil];
                });
            });
            
            it(@"accepts a nil success block", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient saveCardWithNumber:@"4111111111111111" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                           postalCode:nil validate:YES success:nil failure:nil];
                    
                    wait_for_potential_async_exceptions(done);
                });
            });
            
            it(@"accepts a nil failure block", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient saveCardWithNumber:@"4111111111111112" expirationMonth:@"12" expirationYear:@"2038" cvv:nil
                                           postalCode:nil validate:YES success:nil failure:nil];
                    
                    wait_for_potential_async_exceptions(done);
                });
            });
            
            it(@"assigns distinct nonces for each payment method", ^{
                expect([paymentMethods[0] nonce]).notTo.equal([paymentMethods[1] nonce]);
            });
#pragma clang diagnostic pop
        });
        
        describe(@"save Paypal account", ^{
            it(@"returns the newly saved account", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient savePaypalPaymentMethodWithAuthCode:@"authCode"
                                              applicationCorrelationID:@"correlationId"
                                                               success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                   expect(paypalPaymentMethod.nonce).to.beANonce();
                                                                   expect(paypalPaymentMethod.email).to.endWith(@"@example.com");
                                                                   done();
                                                               } failure:nil];
                });
            });
        });
        
        
        describe(@"fetch payment methods", ^{
            it(@"initialy retrieves an empty list", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
                        expect(paymentMethods).to.haveCountOf(0);
                        done();
                    } failure:nil];
                });
            });
            
            describe(@"with two payment methods on file", ^{
                __block NSArray *paymentMethods;
                
                beforeEach(^{
                    waitUntil(^(DoneCallback done) {
                        BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
                        request.number = @"4111111111111111";
                        request.expirationMonth = @"12";
                        request.expirationYear = @"2038";
                        request.shouldValidate = YES;
                        [offlineClient saveCardWithRequest:request
                                                   success:^(BTPaymentMethod *card){
                                                       [offlineClient savePaypalPaymentMethodWithAuthCode:@"authCode"
                                                                                 applicationCorrelationID:@""
                                                                                                  success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                                                      [offlineClient fetchPaymentMethodsWithSuccess:^(NSArray *fetchedPaymentMethods) {
                                                                                                          paymentMethods = fetchedPaymentMethods;
                                                                                                          done();
                                                                                                      } failure:nil];
                                                                                                  } failure:nil];
                                                   }
                                                   failure:nil];
                    });
                });
                
                it(@"returns the list of payment methods", ^{
                    expect(paymentMethods).to.haveCountOf(2);
                    expect([paymentMethods[0] nonce]).to.beANonce();
                    expect([paymentMethods[1] nonce]).to.beANonce();
                });
                
                it(@"includes saved cards", ^{
                    expect(paymentMethods[1]).to.beKindOf([BTCardPaymentMethod class]);
                    expect([paymentMethods[1] lastTwo]).to.equal(@"11");
                });
                
                it(@"includes saved PayPal accounts", ^{
                    expect(paymentMethods[0]).to.beKindOf([BTPayPalPaymentMethod class]);
                    expect([paymentMethods[0] email]).to.endWith(@"@example.com");
                });
                
                it(@"assigns distinct nonces for each payment method", ^{
                    expect([paymentMethods[0] nonce]).notTo.equal([paymentMethods[1] nonce]);
                });
            });
            
            it(@"accepts a nil success block", ^{
                waitUntil(^(DoneCallback done) {
                    [offlineClient fetchPaymentMethodsWithSuccess:nil failure:nil];
                    
                    wait_for_potential_async_exceptions(done);
                });
            });
        });
    });
});

SpecEnd
