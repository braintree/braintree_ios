#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalRequest.h>
#else
#import <BraintreePayPal/BTPayPalRequest.h>
#endif

@implementation BTPayPalRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shippingAddressRequired = NO;
        _offerCredit = NO;
        _offerPayLater = NO;
        _shippingAddressEditable = NO;
        _requestBillingAgreement = NO;
        _intent = BTPayPalRequestIntentAuthorize;
        _userAction = BTPayPalRequestUserActionDefault;
        _landingPageType = BTPayPalRequestLandingPageTypeDefault;
    }
    return self;
}

- (instancetype)initWithAmount:(NSString *)amount {
    if (amount == nil) {
        return nil;
    }

    if (self = [self init]) {
        _amount = amount;
    }
    return self;
}

@end
