#import "BTDataCollector.h"
#import "DeviceCollectorSDK.h"

@interface BTDataCollector () <DeviceCollectorSDKDelegate>

/// The Kount SDK device collector, exposed internally for testing
@property (nonatomic, strong, nonnull) DeviceCollectorSDK *kount;

/// The `PPDataCollector` class, exposed internally for injecting test doubles for unit tests
+ (void)setPayPalDataCollectorClass:(nonnull Class)payPalDataCollectorClass;

@end
