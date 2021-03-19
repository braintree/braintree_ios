#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2UICustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2UICustomization.h>
#endif

#import <CardinalMobile/CardinalMobile.h>

@interface BTThreeDSecureV2UICustomization ()

@property (nonatomic, strong) UiCustomization *cardinalValue;

@end
