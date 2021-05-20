#import "BTPayPalAccountNonce_Internal.h"
#import "BTPayPalCreditFinancing_Internal.h"
#import "BTPayPalCreditFinancingAmount_Internal.h"

@interface BTPayPalAccountNonce ()

@property (nonatomic, readwrite, copy) NSString *email;
@property (nonatomic, readwrite, copy) NSString *firstName;
@property (nonatomic, readwrite, copy) NSString *lastName;
@property (nonatomic, readwrite, copy) NSString *phone;
@property (nonatomic, readwrite, strong) BTPostalAddress *billingAddress;
@property (nonatomic, readwrite, strong) BTPostalAddress *shippingAddress;
@property (nonatomic, readwrite, copy) NSString *clientMetadataID;
@property (nonatomic, readwrite, copy) NSString *payerID;
@property (nonatomic, readwrite, strong) BTPayPalCreditFinancing *creditFinancing;

@end

@implementation BTPayPalAccountNonce

- (nullable instancetype)initWithJSON:(BTJSON *)json {
    BTJSON *payPalAccount = json[@"paypalAccounts"].asArray.firstObject;
    NSString *nonce = payPalAccount[@"nonce"].asString;
    BOOL isDefault = payPalAccount[@"default"].isTrue;

    if (self = [super initWithNonce:nonce type:@"PayPal" isDefault:isDefault]) {
        BTJSON *details = payPalAccount[@"details"];
        _email = details[@"email"].asString ?: details[@"payerInfo"][@"email"].asString;
        _clientMetadataID = details[@"correlationId"].asString;
        _firstName = details[@"payerInfo"][@"firstName"].asString;
        _lastName = details[@"payerInfo"][@"lastName"].asString;
        _phone = details[@"payerInfo"][@"phone"].asString;
        _payerID = details[@"payerInfo"][@"payerId"].asString;

        BTJSON *shippingAddressJSON = details[@"payerInfo"][@"shippingAddress"];
        BTJSON *accountAddressJSON = details[@"payerInfo"][@"accountAddress"];

        BTPostalAddress *shippingAddress = [[BTPostalAddress alloc] init];

        if (shippingAddressJSON.isObject) {
            shippingAddress.recipientName = shippingAddressJSON[@"recipientName"].asString;
            shippingAddress.streetAddress = shippingAddressJSON[@"line1"].asString;
            shippingAddress.extendedAddress = shippingAddressJSON[@"line2"].asString;
            shippingAddress.locality = shippingAddressJSON[@"city"].asString;
            shippingAddress.region = shippingAddressJSON[@"state"].asString;
            shippingAddress.postalCode = shippingAddressJSON[@"postalCode"].asString;
            shippingAddress.countryCodeAlpha2 = shippingAddressJSON[@"countryCode"].asString;
        } else {
            shippingAddress.recipientName = accountAddressJSON[@"recipientName"].asString;
            shippingAddress.streetAddress = accountAddressJSON[@"street1"].asString;
            shippingAddress.extendedAddress = accountAddressJSON[@"street2"].asString;
            shippingAddress.locality = accountAddressJSON[@"city"].asString;
            shippingAddress.region = accountAddressJSON[@"state"].asString;
            shippingAddress.postalCode = accountAddressJSON[@"postalCode"].asString;
            shippingAddress.countryCodeAlpha2 = accountAddressJSON[@"countryCode"].asString;
        }

        _shippingAddress = shippingAddress;

        BTJSON *billingAddressJSON = details[@"payerInfo"][@"billingAddress"];
        BTPostalAddress *billingAddress = [[BTPostalAddress alloc] init];
        billingAddress.recipientName = billingAddressJSON[@"recipientName"].asString;
        billingAddress.streetAddress = billingAddressJSON[@"line1"].asString;
        billingAddress.extendedAddress = billingAddressJSON[@"line2"].asString;
        billingAddress.locality = billingAddressJSON[@"city"].asString;
        billingAddress.region = billingAddressJSON[@"state"].asString;
        billingAddress.postalCode = billingAddressJSON[@"postalCode"].asString;
        billingAddress.countryCodeAlpha2 = billingAddressJSON[@"countryCode"].asString;

        _billingAddress = billingAddress;

        BTJSON *creditFinancingJSON = details[@"creditFinancingOffered"];

        BOOL cardAmountImmutable = creditFinancingJSON[@"cardAmountImmutable"].isTrue;
        BOOL payerAcceptance = creditFinancingJSON[@"payerAcceptance"].isTrue;
        NSUInteger term = creditFinancingJSON[@"term"].asIntegerOrZero;

        BTJSON *monthlyPaymentJSON = creditFinancingJSON[@"monthlyPayment"];
        BTPayPalCreditFinancingAmount *monthlyPayment;
        if (monthlyPaymentJSON.isObject) {
            monthlyPayment = [[BTPayPalCreditFinancingAmount alloc] initWithCurrency:monthlyPaymentJSON[@"currency"].asString
                                                                               value:monthlyPaymentJSON[@"value"].asString];
        }

        BTJSON *totalCostJSON = creditFinancingJSON[@"totalCost"];
        BTPayPalCreditFinancingAmount *totalCost;
        if (totalCostJSON.isObject) {
            totalCost = [[BTPayPalCreditFinancingAmount alloc] initWithCurrency:totalCostJSON[@"currency"].asString
                                                                          value:totalCostJSON[@"value"].asString];
        }

        BTJSON *totalInterestJSON = creditFinancingJSON[@"totalInterest"];
        BTPayPalCreditFinancingAmount *totalInterest;
        if (totalInterestJSON.isObject) {
            totalInterest = [[BTPayPalCreditFinancingAmount alloc] initWithCurrency:totalInterestJSON[@"currency"].asString
                                                                              value:totalInterestJSON[@"value"].asString];
        }

        _creditFinancing = [[BTPayPalCreditFinancing alloc] initWithCardAmountImmutable:cardAmountImmutable
                                                                         monthlyPayment:monthlyPayment
                                                                        payerAcceptance:payerAcceptance
                                                                                   term:term
                                                                              totalCost:totalCost
                                                                          totalInterest:totalInterest];
    }
    return self;
}

- (instancetype)initWithNonce:(NSString *)nonce
                        email:(NSString *)email
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        phone:(NSString *)phone
               billingAddress:(BTPostalAddress *)billingAddress
              shippingAddress:(BTPostalAddress *)shippingAddress
             clientMetadataID:(NSString *)clientMetadataID
                      payerID:(NSString *)payerID
                    isDefault:(BOOL)isDefault
              creditFinancing:(BTPayPalCreditFinancing *)creditFinancing {
    if (self = [super initWithNonce:nonce type:@"PayPal" isDefault:isDefault]) {
        _email = email;
        _firstName = firstName;
        _lastName = lastName;
        _phone = phone;
        _billingAddress = [billingAddress copy];
        _shippingAddress = [shippingAddress copy];
        _clientMetadataID = clientMetadataID;
        _payerID = payerID;
        _creditFinancing = creditFinancing;
    }
    return self;
}

@end
