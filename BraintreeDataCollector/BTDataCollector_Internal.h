#import "BTDataCollector.h"
#import "KDataCollector.h"

@interface BTDataCollector ()

/**
 The Kount SDK device collector, exposed internally for testing
*/
@property (nonatomic, strong, nonnull) KDataCollector *kount;

/**
 The `PPDataCollector` class, exposed internally for injecting test doubles for unit tests
*/
+ (void)setPayPalDataCollectorClass:(nonnull Class)payPalDataCollectorClass;

@end

