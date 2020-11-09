#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTErrors.h>
#else
#import <BraintreeCore/BTErrors.h>
#endif

#pragma mark Error userInfo Keys

NSString *const BTCustomerInputBraintreeValidationErrorsKey = @"BTCustomerInputBraintreeValidationErrorsKey";
