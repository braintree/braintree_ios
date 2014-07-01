#ifdef __LP64__

#import "DeviceCollectorSDK.h"

/// The version of libDeviceCollectorLibrary.a vendored in this SDK does not include arm64 or
/// x86_64 slices. As a workaround, this shim provides no-op implementations for
/// DeviceCollectorSDK's public interface.
@implementation DeviceCollectorSDK

- (DeviceCollectorSDK *)initWithDebugOn:(bool)debugLogging {
    return nil;
}

- (void)setCollectorUrl:(NSString *)url {
}

- (void)setMerchantId:(NSString *)merc {
}

- (void)collect:(NSString *)sessionId {
}

- (void)setDelegate:(id<DeviceCollectorSDKDelegate>)delegate {
}


@end

#endif