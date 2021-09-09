#import "BTCard_Internal.h"

#if __has_include(<Braintree/BraintreeCard.h>)
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTCard ()

@property (nonatomic, strong, readonly) NSString *cardTokenizationGraphQLMutation;

@end

@implementation BTCard

#pragma mark -

- (NSDictionary *)parameters {
    NSMutableDictionary *p = [NSMutableDictionary new];
    if (self.number) {
        p[@"number"] = self.number;
    }

    if (self.expirationMonth) {
        p[@"expiration_month"] = self.expirationMonth;
    }

    if (self.expirationYear) {
        p[@"expiration_year"] = self.expirationYear;
    }

    if (self.cardholderName) {
        p[@"cardholder_name"] = self.cardholderName;
    }

    if (self.expirationMonth && self.expirationYear) {
        p[@"expiration_date"] = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
    }
    
    if (self.cvv) {
        p[@"cvv"] = self.cvv;
    }
    
    NSMutableDictionary *billingAddressDictionary = [NSMutableDictionary new];
    
    if (self.firstName) {
        billingAddressDictionary[@"first_name"] = self.firstName;
    }
    
    if (self.lastName) {
        billingAddressDictionary[@"last_name"] = self.lastName;
    }

    if (self.company) {
        billingAddressDictionary[@"company"] = self.company;
    }

    if (self.postalCode) {
        billingAddressDictionary[@"postal_code"] = self.postalCode;
    }
    
    if (self.streetAddress) {
        billingAddressDictionary[@"street_address"] = self.streetAddress;
    }

    if (self.extendedAddress) {
        billingAddressDictionary[@"extended_address"] = self.extendedAddress;
    }
    
    if (self.locality) {
        billingAddressDictionary[@"locality"] = self.locality;
    }
    
    if (self.region) {
        billingAddressDictionary[@"region"] = self.region;
    }
    
    if (self.countryName) {
        billingAddressDictionary[@"country_name"] = self.countryName;
    }
    
    if (self.countryCodeAlpha2) {
        billingAddressDictionary[@"country_code_alpha2"] = self.countryCodeAlpha2;
    }

    if (self.countryCodeAlpha3) {
        billingAddressDictionary[@"country_code_alpha3"] = self.countryCodeAlpha3;
    }

    if (self.countryCodeNumeric) {
        billingAddressDictionary[@"country_code_numeric"] = self.countryCodeNumeric;
    }

    if (billingAddressDictionary.count > 0) {
        p[@"billing_address"] = [billingAddressDictionary copy];
    }

    p[@"options"] = @{@"validate" : @(self.shouldValidate)};
    return [p copy];
}

- (NSDictionary *)graphQLParameters {
    NSMutableDictionary *inputDictionary = [NSMutableDictionary new];
    NSMutableDictionary *cardDictionary = [NSMutableDictionary new];
    inputDictionary[@"creditCard"] = cardDictionary;

    if (self.number) {
        cardDictionary[@"number"] = self.number;
    }
    if (self.expirationMonth) {
        cardDictionary[@"expirationMonth"] = self.expirationMonth;
    }
    if (self.expirationYear) {
        cardDictionary[@"expirationYear"] = self.expirationYear;
    }
    if (self.cvv) {
        cardDictionary[@"cvv"] = self.cvv;
    }
    if (self.cardholderName) {
        cardDictionary[@"cardholderName"] = self.cardholderName;
    }

    NSMutableDictionary *billingAddressDictionary = [NSMutableDictionary new];

    if (self.firstName) {
        billingAddressDictionary[@"firstName"] = self.firstName;
    }

    if (self.lastName) {
        billingAddressDictionary[@"lastName"] = self.lastName;
    }

    if (self.company) {
        billingAddressDictionary[@"company"] = self.company;
    }

    if (self.postalCode) {
        billingAddressDictionary[@"postalCode"] = self.postalCode;
    }

    if (self.streetAddress) {
        billingAddressDictionary[@"streetAddress"] = self.streetAddress;
    }

    if (self.extendedAddress) {
        billingAddressDictionary[@"extendedAddress"] = self.extendedAddress;
    }

    if (self.locality) {
        billingAddressDictionary[@"locality"] = self.locality;
    }

    if (self.region) {
        billingAddressDictionary[@"region"] = self.region;
    }

    if (self.countryName) {
        billingAddressDictionary[@"countryName"] = self.countryName;
    }

    if (self.countryCodeAlpha2) {
        billingAddressDictionary[@"countryCodeAlpha2"] = self.countryCodeAlpha2;
    }

    if (self.countryCodeAlpha3) {
        billingAddressDictionary[@"countryCode"] = self.countryCodeAlpha3;
    }

    if (self.countryCodeNumeric) {
        billingAddressDictionary[@"countryCodeNumeric"] = self.countryCodeNumeric;
    }

    if (billingAddressDictionary.count > 0) {
        cardDictionary[@"billingAddress"] = [billingAddressDictionary copy];
    }

    inputDictionary[@"options"] = @{@"validate" : @(self.shouldValidate)};

    NSMutableDictionary *variables = [@{ @"input": [inputDictionary copy] } mutableCopy];
    if (self.authenticationInsightRequested) {
        variables[@"authenticationInsightInput"] = self.merchantAccountID ? @{ @"merchantAccountId": self.merchantAccountID } : @{};
    }
    
    return @{
             @"operationName": @"TokenizeCreditCard",
             @"query": self.cardTokenizationGraphQLMutation,
             @"variables": variables
             };
}

- (NSString *)cardTokenizationGraphQLMutation {
    NSMutableString *mutation = [@"mutation TokenizeCreditCard($input: TokenizeCreditCardInput!" mutableCopy];
    
    if (self.authenticationInsightRequested) {
        [mutation appendString:@", $authenticationInsightInput: AuthenticationInsightInput!"];
    }
    
    [mutation appendString:@""
     ") {"
     "  tokenizeCreditCard(input: $input) {"
     "    token"
     "    creditCard {"
     "      brand"
     "      expirationMonth"
     "      expirationYear"
     "      cardholderName"
     "      last4"
     "      bin"
     "      binData {"
     "        prepaid"
     "        healthcare"
     "        debit"
     "        durbinRegulated"
     "        commercial"
     "        payroll"
     "        issuingBank"
     "        countryOfIssuance"
     "        productId"
     "      }"
     "    }"
     ];
    
    if (self.authenticationInsightRequested) {
        [mutation appendString:@""
         "    authenticationInsight(input: $authenticationInsightInput) {"
         "      customerAuthenticationRegulationEnvironment"
         "    }"
         ];
    }
    
    [mutation appendString:@""
     "  }"
     "}"
     ];
    
    return mutation;
}

@end
