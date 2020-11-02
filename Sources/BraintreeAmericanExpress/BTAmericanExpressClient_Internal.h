#if __has_include(<Braintree/BraintreeAmericanExpress.h>)
#import <Braintree/BTAmericanExpressClient.h>
#else
#import <BraintreeAmericanExpress/BTAmericanExpressClient.h>
#endif

@interface BTAmericanExpressClient ()
/**
 Exposed for testing to get the instance of BTAPIClient
 */
@property (nonatomic, strong) BTAPIClient *apiClient;

@end

