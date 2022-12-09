#import "BTPayPalAccountNonce_Internal.h"
#import "BTPayPalCreditFinancing_Internal.h"
#import "BTPayPalCreditFinancingAmount_Internal.h"

// MARK: - Swift File Imports for Package Managers
#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCore;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

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
    if (self) {
        _nonce = nonce;
        _type = @"PayPal";
        _isDefault = isDefault;
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

- (instancetype)initWithJSON:(BTJSON *)json {
    BTJSON *details = json[@"details"];
    BTJSON *payerInfo = details[@"payerInfo"];

    BTJSON *billingAddress = payerInfo[@"billingAddress"];
    BTJSON *shippingAddress = payerInfo[@"shippingAddress"];
    BTJSON *creditFinancing = details[@"creditFinancingOffered"];

    return [[[self class] alloc] initWithNonce:[json[@"nonce"] asString]
                                         email:[details[@"email"] asString]
                                     firstName:[payerInfo[@"firstName"] asString]
                                      lastName:[payerInfo[@"lastName"] asString]
                                         phone:[payerInfo[@"phone"] asString]
                                billingAddress:[self.class addressFromJSON:billingAddress]
                               shippingAddress:[self.class addressFromJSON:shippingAddress]
                              clientMetadataID:[payerInfo[@"correlationId"] asString]
                                       payerID:[payerInfo[@"payerId"] asString]
                                     isDefault:[json[@"default"] isTrue]
                               creditFinancing:[self.class creditFinancingFromJSON:creditFinancing]];
}

+ (BTPostalAddress *)addressFromJSON:(BTJSON *)addressJSON {
    if (!addressJSON.isObject) {
        return nil;
    }

    BTPostalAddress *address = [[BTPostalAddress alloc] init];
    address.recipientName = [addressJSON[@"recipientName"] asString]; // Likely to be nil
    address.streetAddress = [addressJSON[@"street1"] asString];
    address.extendedAddress = [addressJSON[@"street2"] asString];
    address.locality = [addressJSON[@"city"] asString];
    address.region = [addressJSON[@"state"] asString];
    address.postalCode = [addressJSON[@"postalCode"] asString];
    address.countryCodeAlpha2 = [addressJSON[@"country"] asString];

    return address;
}

+ (BTPayPalCreditFinancing *)creditFinancingFromJSON:(BTJSON *)creditFinancingOfferedJSON {
    if (!creditFinancingOfferedJSON.isObject) {
        return nil;
    }

    BOOL isCardAmountImmutable = [creditFinancingOfferedJSON[@"cardAmountImmutable"] isTrue];

    BTPayPalCreditFinancingAmount *monthlyPayment = [self.class creditFinancingAmountFromJSON:creditFinancingOfferedJSON[@"monthlyPayment"]];

    BOOL payerAcceptance = [creditFinancingOfferedJSON[@"payerAcceptance"] isTrue];
    NSInteger term = [creditFinancingOfferedJSON[@"term"] asIntegerOrZero];
    BTPayPalCreditFinancingAmount *totalCost = [self.class creditFinancingAmountFromJSON:creditFinancingOfferedJSON[@"totalCost"]];
    BTPayPalCreditFinancingAmount *totalInterest = [self.class creditFinancingAmountFromJSON:creditFinancingOfferedJSON[@"totalInterest"]];

    return [[BTPayPalCreditFinancing alloc] initWithCardAmountImmutable:isCardAmountImmutable
                                                         monthlyPayment:monthlyPayment
                                                        payerAcceptance:payerAcceptance
                                                                   term:term
                                                              totalCost:totalCost
                                                          totalInterest:totalInterest];
}

+ (BTPayPalCreditFinancingAmount *)creditFinancingAmountFromJSON:(BTJSON *)amountJSON {
    if (!amountJSON.isObject) {
        return nil;
    }

    NSString *currency = [amountJSON[@"currency"] asString];
    NSString *value = [amountJSON[@"value"] asString];

    return [[BTPayPalCreditFinancingAmount alloc] initWithCurrency:currency value:value];
}

@end
