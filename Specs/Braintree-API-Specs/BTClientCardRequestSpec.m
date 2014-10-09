#import "BTClientCardRequest.h"
#import "BTClientCardTokenizationRequest.h"

SpecBegin(BTClientCardRequest)

describe(@"cardPaymentMethodParameters", ^{
    it(@"constructs parameters for creating a new payment method", ^{
        BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
        request.number = @"4111111111111111";
        request.expirationMonth = @"12";
        request.expirationYear = @"2038";
        request.expirationDate = @"12/2038";
        request.cvv = @"100";
        request.postalCode = @"10000";
        request.shouldValidate = NO;
        request.additionalParameters = @{ @"cardholder_name": @"John Doe" };

        expect(request.parameters).to.equal(@{ @"number": @"4111111111111111",
                                               @"expiration_month": @"12",
                                               @"expiration_year": @"2038",
                                               @"expiration_date": @"12/2038",
                                               @"cvv": @"100",
                                               @"billing_address": @{
                                                       @"postal_code": @"10000"
                                                       },
                                               @"cardholder_name": @"John Doe",
                                               @"options": @{ @"validate": @NO } });
    });

    it(@"overrides default parameters with additional parameters", ^{
        BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
        request.number = @"4111";
        request.shouldValidate = YES;

        request.additionalParameters = @{ @"number": @"1234", @"options": @{ @"validate": @YES } };

        expect(request.parameters).to.equal(@{ @"number": @"1234", @"options": @{ @"validate": @YES } });
    });


    it(@"overrides default parameters without deeply merging them", ^{
        BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
        request.postalCode = @"60606";
        request.shouldValidate = YES;
        request.additionalParameters = @{
                                         @"billing_address": @{
                                                 @"street_address": @"742 Evergreen Terrace"
                                                 },
                                         @"options": @{
                                                 @"something": @"other than validate"
                                                 }
                                         };

        expect(request.parameters).to.equal(@{ @"billing_address": @{ @"street_address": @"742 Evergreen Terrace" },
                                               @"options": @{ @"something": @"other than validate" }
                                               });
        
    });

    it(@"defaults to shouldValidate NO", ^{
        BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
        expect(request.shouldValidate).to.beFalsy();
    });
});

describe(@"initWithTokenizationRequest:", ^{
    it(@"copies the properties from a tokenization request", ^{
        BTClientCardTokenizationRequest *tokenizationRequest = [[BTClientCardTokenizationRequest alloc] init];
        tokenizationRequest.number = @"4111111111111111";
        tokenizationRequest.expirationMonth = @"12";
        tokenizationRequest.expirationYear = @"2038";
        tokenizationRequest.expirationDate = @"12/2038";
        tokenizationRequest.cvv = @"100";
        tokenizationRequest.postalCode = @"10000";
        tokenizationRequest.additionalParameters = @{ @"cardholder_name": @"John Doe" };

        BTClientCardRequest *cardRequest = [[BTClientCardRequest alloc] initWithTokenizationRequest:tokenizationRequest];
        expect(cardRequest.number).to.equal(tokenizationRequest.number);
        expect(cardRequest.expirationMonth).to.equal(tokenizationRequest.expirationMonth);
        expect(cardRequest.expirationYear).to.equal(tokenizationRequest.expirationYear);
        expect(cardRequest.expirationDate).to.equal(tokenizationRequest.expirationDate);
        expect(cardRequest.cvv).to.equal(tokenizationRequest.cvv);
        expect(cardRequest.postalCode).to.equal(tokenizationRequest.postalCode);
        expect(cardRequest.additionalParameters).to.equal(tokenizationRequest.additionalParameters);

        expect(cardRequest.shouldValidate).to.beFalsy();

        expect(cardRequest.parameters).to.equal(tokenizationRequest.parameters);
    });

    it(@"copies nothing from an empty tokenization request", ^{
        BTClientCardTokenizationRequest *tokenizationRequest = [[BTClientCardTokenizationRequest alloc] init];
        tokenizationRequest.number = @"4111111111111111";
        tokenizationRequest.expirationMonth = @"12";
        tokenizationRequest.expirationYear = @"2038";
        tokenizationRequest.expirationDate = @"12/2038";
        tokenizationRequest.cvv = @"100";
        tokenizationRequest.postalCode = @"10000";
        tokenizationRequest.additionalParameters = @{ @"cardholder_name": @"John Doe" };

        BTClientCardRequest *cardRequest = [[BTClientCardRequest alloc] initWithTokenizationRequest:tokenizationRequest];
        expect(cardRequest.number).to.equal(tokenizationRequest.number);
        expect(cardRequest.expirationMonth).to.equal(tokenizationRequest.expirationMonth);
        expect(cardRequest.expirationYear).to.equal(tokenizationRequest.expirationYear);
        expect(cardRequest.expirationDate).to.equal(tokenizationRequest.expirationDate);
        expect(cardRequest.cvv).to.equal(tokenizationRequest.cvv);
        expect(cardRequest.postalCode).to.equal(tokenizationRequest.postalCode);
        expect(cardRequest.additionalParameters).to.equal(tokenizationRequest.additionalParameters);

        expect(cardRequest.shouldValidate).to.beFalsy();

        expect(cardRequest.parameters).to.equal(tokenizationRequest.parameters);
    });

    it(@"fails to copy from nil", ^{
        BTClientCardRequest *cardRequest = [[BTClientCardRequest alloc] initWithTokenizationRequest:nil];
        expect(cardRequest).to.beNil();
    });
});

SpecEnd
