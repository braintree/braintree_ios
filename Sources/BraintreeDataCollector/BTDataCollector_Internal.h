#import <CoreLocation/CoreLocation.h>
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

// TODO: Annotation for only needed for iOS 14
@property (nonatomic, strong, nonnull) CLLocationManager *locationManager;

@end

