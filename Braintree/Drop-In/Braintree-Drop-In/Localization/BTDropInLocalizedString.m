#import "BTDropInLocalizedString.h"

@implementation BTDropInLocalizedString

+ (NSBundle *)localizationBundle {
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Braintree-DropIn-Localization" ofType:@"bundle"]];
}

+ (NSString *)localizationTable {
    return @"DropIn";
}

+ (NSString *)DROP_IN_CHANGE_PAYMENT_METHOD_BUTTON_TEXT {
    return NSLocalizedStringWithDefaultValue(@"DROP_IN_CHANGE_PAYMENT_METHOD_BUTTON_TEXT", [self localizationTable], [self localizationBundle], @"Change payment method", @"Title text for button on Drop In with a selected payment method that allows user to choose a different payment method on file");
}

+ (NSString *)ERROR_ALERT_OK_BUTTON_TEXT {
    return NSLocalizedStringWithDefaultValue(@"ERROR_ALERT_OK_BUTTON_TEXT", [self localizationTable], [self localizationBundle], @"OK", @"Button text to indicate acceptance of an alert condition");
}


+ (NSString *)ERROR_ALERT_CANCEL_BUTTON_TEXT {
    return NSLocalizedStringWithDefaultValue(@"ERROR_ALERT_CANCEL_BUTTON_TEXT", [self localizationTable], [self localizationBundle], @"Cancel", @"Button text to indicate acceptance of an alert condition");
}

+ (NSString *)ERROR_ALERT_TRY_AGAIN_BUTTON_TEXT {
    return NSLocalizedStringWithDefaultValue(@"ERROR_ALERT_TRY_AGAIN_BUTTON_TEXT", [self localizationTable], [self localizationBundle], @"Try Again", @"Button text to request that an failed operation should be restarted and to try again");
}

+ (NSString *)ERROR_ALERT_CONNECTION_ERROR {
    return NSLocalizedStringWithDefaultValue(@"ERROR_ALERT_CONNECTION_ERROR", [self localizationTable], [self localizationBundle], @"Connection Error", @"Vague title for alert view that ambiguously indicates an unspecified failure");
}

+ (NSString *)PAYPAL {
    return NSLocalizedStringWithDefaultValue(@"PAYPAL", @"DropIn", [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Braintree-Drop-In-Localization" ofType:@"bundle"]], @"PayPal", @"PayPal (as a standalone term, referring to the payment method type, analogous to Visa or Discover");
}

@end
