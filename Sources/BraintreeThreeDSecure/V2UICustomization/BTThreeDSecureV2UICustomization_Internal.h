#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2UICustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2UICustomization.h>
#endif

@interface BTThreeDSecureV2UICustomization ()

@property (nonatomic, strong) id uiCustomization;

@end
