#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTHTTPErrors.h>
#else
#import <BraintreeCore/BTHTTPErrors.h>
#endif

NSString * const BTHTTPErrorDomain = @"com.braintreepayments.BTHTTPErrorDomain";

NSString * const BTHTTPURLResponseKey = @"com.braintreepayments.BTHTTPURLResponseKey";

NSString * const BTHTTPJSONResponseBodyKey = @"com.braintreepayments.BTHTTPJSONResponseBodyKey";
