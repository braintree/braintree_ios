#import "BTClientCardTokenizationRequest.h"

SpecBegin(BTClientCardTokenizationRequest)

describe(@"cardPaymentMethodParameters", ^{
    it(@"constructs parameters for creating a new payment method", ^{
        BTClientCardTokenizationRequest *request = [[BTClientCardTokenizationRequest alloc] init];
        request.number = @"4111111111111111";
        request.expirationMonth = @"12";
        request.expirationYear = @"2038";
        request.cvv = @"100";
        request.postalCode = @"10000";
        request.additionalParameters = @{ @"cardholder_name": @"John Doe" };

        expect(request.parameters).to.equal(@{ @"number": @"4111111111111111",
                                               @"expiration_month": @"12",
                                               @"expiration_year": @"2038",
                                               @"cvv": @"100",
                                               @"billing_address": @{
                                                       @"postal_code": @"10000"
                                                       },
                                               @"cardholder_name": @"John Doe",
                                               @"options": @{ @"validate": @NO } });
    });

    it(@"overrides default parameters with additional parameters", ^{
        BTClientCardTokenizationRequest *request = [[BTClientCardTokenizationRequest alloc] init];
        request.number = @"4111";

        request.additionalParameters = @{ @"number": @"1234", @"options": @{ @"validate": @NO } };

        expect(request.parameters).to.equal(@{ @"number": @"1234", @"options": @{ @"validate": @NO } });
    });

    it(@"always returns should validate false", ^{
        BTClientCardTokenizationRequest *request = [[BTClientCardTokenizationRequest alloc] init];

        expect(request.shouldValidate).to.beFalsy();
        expect(request.parameters).to.equal(@{ @"options": @{ @"validate": @NO } });
    });

    it(@"overrides default parameters without deeply merging them", ^{
        BTClientCardTokenizationRequest *request = [[BTClientCardTokenizationRequest alloc] init];
        request.postalCode = @"60606";
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
});

SpecEnd
