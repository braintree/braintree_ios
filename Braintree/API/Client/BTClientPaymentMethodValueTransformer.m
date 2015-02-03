#import "BTClientPaymentMethodValueTransformer.h"
#import "BTAPIResponseParser.h"
#import "BTMutablePaymentMethod.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTMutablePayPalPaymentMethod.h"
#import "BTMutableApplePayPaymentMethod.h"

@implementation BTClientPaymentMethodValueTransformer

+ (Class)transformedValueClass {
    return [BTPaymentMethod class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
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
        card.typeString = [responseParser[@"details"] stringForKey:@"cardType"];
        card.lastTwo = [responseParser[@"details"] stringForKey:@"lastTwo"];
        card.challengeQuestions = [responseParser setForKey:@"securityQuestions"];
        card.nonce = [responseParser stringForKey:@"nonce"];

        paymentMethod = card;
    } else if ([type isEqualToString:@"PayPalAccount"]) {
        BTMutablePayPalPaymentMethod *payPal = [[BTMutablePayPalPaymentMethod alloc] init];

        payPal.nonce = [responseParser stringForKey:@"nonce"];
        payPal.email = [responseParser[@"details"] stringForKey:@"email"];

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
    } else if ([type isEqualToString:@"ApplePayPayment"]) {
        BTMutableApplePayPaymentMethod *card = [[BTMutableApplePayPaymentMethod alloc] init];

        card.nonce = [responseParser stringForKey:@"nonce"];
        card.description = [responseParser stringForKey:@"description"];
        card.challengeQuestions = [responseParser setForKey:@"securityQuestions"];

        paymentMethod = card;
#endif
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
