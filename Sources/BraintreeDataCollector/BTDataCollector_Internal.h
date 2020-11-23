#if __has_include(<Braintree/BraintreeDataCollector.h>)
#import <Braintree/BTDataCollector.h>
#else
#import <BraintreeDataCollector/BTDataCollector.h>
#endif

@class KDataCollector;

@interface BTDataCollector ()

/**
 The Kount SDK device collector, exposed internally for testing
*/
@property (nonatomic, strong, nonnull) KDataCollector *kount;

@end

