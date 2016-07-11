#import "BTDropInResult.h"
#import "BTUIKViewUtil.h"
#import "BTUIKLocalizedString.h"
#import "BTUIKVectorArtView.h"

@implementation BTDropInResult

- (UIView *)paymentIcon {
    return [BTUIKViewUtil vectorArtViewForPaymentOptionType:self.paymentOptionType];
}

- (NSString *)paymentDescription {
    if (self.paymentMethod != nil) {
        return self.paymentMethod.localizedDescription;
    } else if (self.paymentOptionType == BTUIKPaymentOptionTypeApplePay) {
        return [BTUIKLocalizedString PAYMENT_METHOD_TYPE_APPLE_PAY];
    }
    return @"";
}

@end
