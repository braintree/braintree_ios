#import "BTClientPaymentMethodValueTransformer.h"
#import "BTAPIResponseParser.h"
#import "BTMutablePaymentMethod.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTMutablePayPalPaymentMethod.h"
#import "BTMutableApplePayPaymentMethod.h"
#import "BTCoinbasePaymentMethod_Internal.h"
#import "BTPostalAddress.h"
#import "BTPostalAddress_Internal.h"
#import "BTPayPalPayerInfoHelper.h"

@implementation BTClientPaymentMethodValueTransformer

+ (instancetype)sharedInstance {
    static BTClientPaymentMethodValueTransformer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)transformedValue:(id)value {
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    BTAPIResponseParser *responseParser = [BTAPIResponseParser parserWithDictionary:value];

    BTPaymentMethod *paymentMethod;

    NSString *type = [responseParser stringForKey:@"type"];
    if ([type isEqualToString:@"CreditCard"]) {
        BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];

        card.description = [responseParser stringForKey:@"description"];
        card.typeString = [[responseParser responseParserForKey:@"details"] stringForKey:@"cardType"];
        card.lastTwo = [[responseParser responseParserForKey:@"details"] stringForKey:@"lastTwo"];
        card.challengeQuestions = [responseParser setForKey:@"securityQuestions"];
        card.nonce = [responseParser stringForKey:@"nonce"];
        NSDictionary *threeDSecureInfoDict = [responseParser dictionaryForKey:@"threeDSecureInfo"];
        if (threeDSecureInfoDict) {
            card.threeDSecureInfoDictionary = threeDSecureInfoDict;
        }
        paymentMethod = card;
    } else if ([type isEqualToString:@"PayPalAccount"]) {
        BTMutablePayPalPaymentMethod *payPal = [[BTMutablePayPalPaymentMethod alloc] init];

        payPal.nonce = [responseParser stringForKey:@"nonce"];
        
        BTAPIResponseParser *detailsParser = [responseParser responseParserForKey:@"details"];
        payPal.email = [detailsParser stringForKey:@"email"];
        NSDictionary *payerInfoDict = [detailsParser dictionaryForKey:@"payerInfo"];
        if (payerInfoDict && payerInfoDict[@"email"]) { payPal.email = payerInfoDict[@"email"]; } // Allow email to be under payerInfo
        if (payerInfoDict && payerInfoDict[@"firstName"]) { payPal.firstName = payerInfoDict[@"firstName"]; }
        if (payerInfoDict && payerInfoDict[@"lastName"]) { payPal.lastName = payerInfoDict[@"lastName"]; }
        if (payerInfoDict && payerInfoDict[@"phone"]) { payPal.phone = payerInfoDict[@"phone"]; }

        if (payerInfoDict) {
            NSDictionary *billingAddressJSON = payerInfoDict[BTPostalAddressKeyBillingAddress] ? payerInfoDict[BTPostalAddressKeyBillingAddress] : payerInfoDict[BTPostalAddressKeyAccountAddress];
            NSDictionary *shippingAddressJSON = payerInfoDict[BTPostalAddressKeyShippingAddress];

            payPal.billingAddress = [BTPayPalPayerInfoHelper addressForJSONAddress:billingAddressJSON];
            payPal.shippingAddress = [BTPayPalPayerInfoHelper addressForJSONAddress:];

            // TODO: Ensure that refactored behavior matches the code below:

//        if (payerInfoDict && payerInfoDict[BTPostalAddressKeyAccountAddress]) {
//            NSDictionary *addressDictionary = payerInfoDict[BTPostalAddressKeyAccountAddress];
//            payPal.billingAddress = [[BTPostalAddress alloc] init];
//            payPal.billingAddress.recipientName = addressDictionary[BTPostalAddressKeyRecipientName]; // Likely nil, but doesn't hurt
//            payPal.billingAddress.streetAddress = addressDictionary[BTPostalAddressKeyStreet1];
//            payPal.billingAddress.extendedAddress = addressDictionary[BTPostalAddressKeyStreet2];
//            payPal.billingAddress.locality = addressDictionary[BTPostalAddressKeyCity];
//            payPal.billingAddress.region = addressDictionary[BTPostalAddressKeyState];
//            payPal.billingAddress.postalCode = addressDictionary[BTPostalAddressKeyPostalCode];
//            payPal.billingAddress.countryCodeAlpha2 = addressDictionary[BTPostalAddressKeyCountry];
//        }
//        if (payerInfoDict && payerInfoDict[BTPostalAddressKeyBillingAddress]) {
//            NSDictionary *addressDictionary = payerInfoDict[BTPostalAddressKeyBillingAddress];
//            payPal.billingAddress = [[BTPostalAddress alloc] init];
//            payPal.billingAddress.recipientName = addressDictionary[BTPostalAddressKeyRecipientName]; // Likely nil, but doesn't hurt
//            payPal.billingAddress.streetAddress = addressDictionary[BTPostalAddressKeyLine1];
//            payPal.billingAddress.extendedAddress = addressDictionary[BTPostalAddressKeyLine2];
//            payPal.billingAddress.locality = addressDictionary[BTPostalAddressKeyCity];
//            payPal.billingAddress.region = addressDictionary[BTPostalAddressKeyState];
//            payPal.billingAddress.postalCode = addressDictionary[BTPostalAddressKeyPostalCode];
//            payPal.billingAddress.countryCodeAlpha2 = addressDictionary[BTPostalAddressKeyCountryCode];
//        }
//        if (payerInfoDict && payerInfoDict[BTPostalAddressKeyShippingAddress]) {
//            NSDictionary *addressDictionary = payerInfoDict[BTPostalAddressKeyShippingAddress];
//            if ([addressDictionary count] > 0) {
//                payPal.shippingAddress = [[BTPostalAddress alloc] init];
//                payPal.shippingAddress.recipientName = addressDictionary[BTPostalAddressKeyRecipientName];
//                payPal.shippingAddress.streetAddress = addressDictionary[BTPostalAddressKeyLine1];
//                payPal.shippingAddress.extendedAddress = addressDictionary[BTPostalAddressKeyLine2];
//                payPal.shippingAddress.locality = addressDictionary[BTPostalAddressKeyCity];
//                payPal.shippingAddress.region = addressDictionary[BTPostalAddressKeyState];
//                payPal.shippingAddress.postalCode = addressDictionary[BTPostalAddressKeyPostalCode];
//                payPal.shippingAddress.countryCodeAlpha2 = addressDictionary[BTPostalAddressKeyCountryCode];
//            }
            
        }
        
        // Braintree gateway has some inconsistent behavior depending on
        // the type of nonce, and sometimes returns "PayPal" for description,
        // and sometimes returns a real identifying string. The former is not
        // desirable for display. The latter is.
        // As a workaround, we ignore descriptions that look like "PayPal".
        id description = [responseParser stringForKey:@"description"];
        if (![[description lowercaseString] isEqualToString:@"paypal"]) {
            payPal.description = description;
        }

        paymentMethod = payPal;
#ifdef BT_ENABLE_APPLE_PAY
    } else if ([type isEqualToString:@"ApplePayCard"]) {
        BTMutableApplePayPaymentMethod *card = [[BTMutableApplePayPaymentMethod alloc] init];

        card.nonce = [responseParser stringForKey:@"nonce"];
        card.description = [responseParser stringForKey:@"description"];
        card.challengeQuestions = [responseParser setForKey:@"securityQuestions"];

        paymentMethod = card;
#endif
    } else if ([type isEqualToString:@"CoinbaseAccount"]) {
        BTCoinbasePaymentMethod *coinbaseAccount = [[BTCoinbasePaymentMethod alloc] init];
        coinbaseAccount.nonce = [responseParser stringForKey:@"nonce"];
        coinbaseAccount.email = [[responseParser responseParserForKey:@"details"] stringForKey:@"email"];
        coinbaseAccount.description = coinbaseAccount.email;
        paymentMethod = coinbaseAccount;
    } else {
        BTMutablePaymentMethod *genericPaymentMethod = [[BTMutablePaymentMethod alloc] init];

        genericPaymentMethod.nonce = [responseParser stringForKey:@"nonce"];
        genericPaymentMethod.description = [responseParser stringForKey:@"description"];
        genericPaymentMethod.challengeQuestions = [responseParser setForKey:@"securityQuestions"];

        paymentMethod = genericPaymentMethod;
    }
    
    return paymentMethod;
}

@end
