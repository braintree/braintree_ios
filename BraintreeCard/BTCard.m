#import "BTCard_Internal.h"
#import "BTJSON.h"

@interface BTCard ()
@property (nonatomic, strong) NSMutableDictionary *mutableParameters;
@end

@implementation BTCard

NSString *const BTCardGraphQLTokenizationMutation = @""
"mutation TokenizeCreditCard($input: TokenizeCreditCardInput!) {"
"  tokenizeCreditCard(input: $input) {"
"    token"
"    creditCard {"
"      brand"
"      last4"
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
"  }"
"}";

- (instancetype)init {
    return [self initWithParameters:@{}];
}

- (nonnull instancetype)initWithParameters:(NSDictionary *)parameters {
    if (self = [super init]) {
        _mutableParameters = [parameters mutableCopy];
        _number = parameters[@"number"];
        NSArray *components = [parameters[@"expiration_date"] componentsSeparatedByString:@"/"];
        if (components.count == 2) {
            _expirationMonth = components[0];
            _expirationYear = components[1];
        }
        _postalCode = parameters[@"billing_address"][@"postal_code"];
        _cvv = parameters[@"cvv"];
        
        _streetAddress = parameters[@"billing_address"][@"street_address"];
        _extendedAddress = parameters[@"billing_address"][@"extended_address"];
        _locality = parameters[@"billing_address"][@"locality"];
        _region = parameters[@"billing_address"][@"region"];
        _countryName = parameters[@"billing_address"][@"country_name"];
        _countryCodeAlpha2 = parameters[@"billing_address"][@"country_code_alpha2"];
        _countryCodeAlpha3 = parameters[@"billing_address"][@"country_code_alpha3"];
        _countryCodeNumeric = parameters[@"billing_address"][@"country_code_numeric"];
        _cardholderName = parameters[@"cardholder_name"];
        _firstName = parameters[@"billing_address"][@"first_name"];
        _lastName = parameters[@"billing_address"][@"last_name"];
        _company = parameters[@"billing_address"][@"company"];
        
        _shouldValidate = [parameters[@"options"][@"validate"] boolValue];
    }
    return self;
}

- (instancetype)initWithNumber:(NSString *)number
               expirationMonth:(NSString *)expirationMonth
                expirationYear:(NSString *)expirationYear
                           cvv:(NSString *)cvv
{
    if (self = [self initWithParameters:@{}]) {
        _number = number;
        _expirationMonth = expirationMonth;
        _expirationYear = expirationYear;
        _cvv = cvv;
    }
    return self;
}

#pragma mark -

- (NSDictionary *)parameters {
    NSMutableDictionary *p = [self.mutableParameters mutableCopy];
    if (self.number) {
        p[@"number"] = self.number;
    }
    if (self.expirationMonth && self.expirationYear) {
        p[@"expiration_date"] = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
    }
    if (self.cvv) {
        p[@"cvv"] = self.cvv;
    }
    if (self.cardholderName) {
        p[@"cardholder_name"] = self.cardholderName;
    }
    
    NSMutableDictionary *billingAddressDictionary = [NSMutableDictionary new];
    if ([p[@"billing_address"] isKindOfClass:[NSDictionary class]]) {
        [billingAddressDictionary addEntriesFromDictionary:p[@"billing_address"]];
    }
    
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
    
    NSMutableDictionary *optionsDictionary = [NSMutableDictionary new];
    if ([p[@"options"] isKindOfClass:[NSDictionary class]]) {
        [optionsDictionary addEntriesFromDictionary:p[@"options"]];
    }
    optionsDictionary[@"validate"] = @(self.shouldValidate);
    p[@"options"] = [optionsDictionary copy];
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
    if ([cardDictionary[@"billingAddress"] isKindOfClass:[NSDictionary class]]) {
        [billingAddressDictionary addEntriesFromDictionary:cardDictionary[@"billingAddress"]];
    }

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

    NSMutableDictionary *optionsDictionary = [NSMutableDictionary new];
    if ([inputDictionary[@"options"] isKindOfClass:[NSDictionary class]]) {
        [optionsDictionary addEntriesFromDictionary:inputDictionary[@"options"]];
    }
    optionsDictionary[@"validate"] = @(self.shouldValidate);
    inputDictionary[@"options"] = [optionsDictionary copy];

    return @{
             @"operationName": @"TokenizeCreditCard",
             @"query": BTCardGraphQLTokenizationMutation,
             @"variables": @{
                     @"input": [inputDictionary copy]
                     }
             };
}

@end
