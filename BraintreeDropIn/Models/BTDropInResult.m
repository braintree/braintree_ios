#import "BTDropInResult.h"
#import "BTKViewUtil.h"
#import "BTKLocalizedString.h"
#import "BTKVectorArtView.h"

@implementation BTDropInResult

- (UIView *)paymentIcon {
    return [BTKViewUtil vectorArtViewForPaymentOptionType:self.paymentOptionType];
}

- (NSString *)paymentDescription {
    if (self.paymentMethod != nil) {
        return self.paymentMethod.localizedDescription;
    } else if (self.paymentOptionType == BTKPaymentOptionTypeApplePay) {
        return [BTKLocalizedString PAYMENT_METHOD_TYPE_APPLE_PAY];
    }
    return @"";
}

@end
