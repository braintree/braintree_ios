#import "Braintree.h"
#import "BTClient.h"
#import "BTCardPaymentMethod.h"
#import "BTPayPalPaymentMethod.h"
#import "BTErrors.h"

SpecBegin(PublicInterfaceSanityCheck)

describe(@"the public facing API guaranteed to be stable in this version of the SDK", ^{
    it(@"includes Braintree", ^{
        Braintree *braintree = [OCMockObject mockForClass:[Braintree class]];
        expect([Braintree class]).to.respondTo(@selector(braintreeWithClientToken:));
        expect(braintree).to.respondTo(@selector(dropInViewControllerWithDelegate:));
        expect(braintree).to.respondTo(@selector(payPalButtonWithDelegate:));
        expect(braintree).to.respondTo(@selector(tokenizeCardWithNumber:expirationMonth:expirationYear:completion:));
        expect([Braintree class]).to.respondTo(@selector(libraryVersion));
        expect(braintree).to.respondTo(@selector(client));
    });

    it(@"includes BTClient", ^{
        BTClient *client = [OCMockObject mockForClass:[BTClient class]];
        expect(client).to.respondTo(@selector(initWithClientToken:));
        expect(client).to.respondTo(@selector(challenges));
        expect(client).to.respondTo(@selector(fetchPaymentMethodsWithSuccess:failure:));
        expect(client).to.respondTo(@selector(saveCardWithNumber:expirationMonth:expirationYear:cvv:postalCode:validate:success:failure:));
        expect(client).to.respondTo(@selector(savePaypalPaymentMethodWithAuthCode:success:failure:));
        expect(client).to.respondTo(@selector(savePaypalPaymentMethodWithAuthCode:applicationCorrelationID:success:failure:));
    });

    it(@"includes BTPayPalButon", ^{
        BTPayPalButton *payPalButton = [OCMockObject mockForClass:[BTPayPalButton class]];
        expect(payPalButton).to.respondTo(@selector(delegate));
        expect(payPalButton).to.respondTo(@selector(presentationDelegate));
        expect(payPalButton).to.respondTo(@selector(client));
        expect(payPalButton).to.respondTo(@selector(setClient:));
    });

    it(@"includes BTPayPalButonDelegate", ^{
        id<BTPayPalButtonDelegate> payPalButtonDelegate = [OCMockObject niceMockForProtocol:@protocol(BTPayPalButtonDelegate)];
        expect(payPalButtonDelegate).to.respondTo(@selector(payPalButton:didCreatePayPalPaymentMethod:));
        expect(payPalButtonDelegate).to.respondTo(@selector(payPalButton:didFailWithError:));
        expect(payPalButtonDelegate).to.respondTo(@selector(payPalButtonWillCreatePayPalPaymentMethod:));
    });

    it(@"includes BTPayPalViewController", ^{
        BTPayPalViewController *payPalViewController = [OCMockObject mockForClass:[BTPayPalViewController class]];
        expect(payPalViewController).to.respondTo(@selector(delegate));
        expect(payPalViewController).to.respondTo(@selector(initWithClient:));
        expect(payPalViewController).to.respondTo(@selector(client));
        expect(payPalViewController).to.respondTo(@selector(setClient:));
    });

    it(@"includes BTPayPalViewControllerDelegate", ^{
        id<BTPayPalViewControllerDelegate> payPalViewControllerDelegate = [OCMockObject niceMockForProtocol:@protocol(BTPayPalViewControllerDelegate)];
        expect(payPalViewControllerDelegate).to.respondTo(@selector(payPalViewControllerWillCreatePayPalPaymentMethod:));
        expect(payPalViewControllerDelegate).to.respondTo(@selector(payPalViewController:didCreatePayPalPaymentMethod:));
        expect(payPalViewControllerDelegate).to.respondTo(@selector(payPalViewController:didFailWithError:));
        expect(payPalViewControllerDelegate).to.respondTo(@selector(payPalViewControllerDidCancel:));
    });

    it(@"includes BTCardPaymentMethod", ^{
        BTCardPaymentMethod *cardPaymentMethod = [OCMockObject mockForClass:[BTCardPaymentMethod class]];
        expect(cardPaymentMethod).to.respondTo(@selector(type));
        expect(cardPaymentMethod).to.respondTo(@selector(typeString));
        expect(cardPaymentMethod).to.respondTo(@selector(lastTwo));
        expect(cardPaymentMethod).to.respondTo(@selector(nonce));
    });

    it(@"includes BTPayPalPaymentMethod", ^{
        BTPayPalPaymentMethod *payPalPaymentMethod = [OCMockObject mockForClass:[BTPayPalPaymentMethod class]];
        expect(payPalPaymentMethod).to.respondTo(@selector(email));
        expect(payPalPaymentMethod).to.respondTo(@selector(nonce));
    });

    it(@"includes BTError", ^{
        expect(BTBraintreeAPIErrorDomain).to.beKindOf([NSString class]);
        expect(BTCustomerInputBraintreeValidationErrorsKey).to.beKindOf([NSString class]);

        expect(BTUnknownError).notTo.beNil();
        expect(BTCustomerInputErrorUnknown).notTo.beNil();
        expect(BTCustomerInputErrorInvalid).notTo.beNil();
        expect(BTMerchantIntegrationErrorUnauthorized).notTo.beNil();
        expect(BTMerchantIntegrationErrorNotFound).notTo.beNil();
        expect(BTMerchantIntegrationErrorInvalidClientToken).notTo.beNil();
        expect(BTMerchantIntegrationErrorNonceNotFound).notTo.beNil();
        expect(BTServerErrorUnknown).notTo.beNil();
        expect(BTServerErrorGatewayUnavailable).notTo.beNil();
        expect(BTServerErrorNetworkUnavailable).notTo.beNil();
        expect(BTServerErrorNetworkUnavailable).notTo.beNil();
        expect(BTServerErrorUnexpectedError).notTo.beNil();

        expect(BTBraintreePayPalErrorDomain).to.beKindOf([NSString class]);
        expect(BTMerchantIntegrationErrorPayPalConfiguration).notTo.beNil();
    });
});

SpecEnd