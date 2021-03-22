#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2BaseCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2BaseCustomization.h>
#endif

#import <CardinalMobile/CardinalMobile.h>

@interface BTThreeDSecureV2BaseCustomization ()

@property (nonatomic, strong) Customization *cardinalValue;

@end
