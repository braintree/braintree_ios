#ifdef __LP64__

#import "DeviceCollectorSDK.h"

/// The version of libDeviceCollectorLibrary.a vendored in this SDK does not include arm64 or
/// x86_64 slices. As a workaround, this shim provides no-op implementations for
/// DeviceCollectorSDK's public interface.
@implementation DeviceCollectorSDK

- (DeviceCollectorSDK *)initWithDebugOn:(__unused BOOL)debugLogging {
    return nil;
}

- (void)setCollectorUrl:(__unused NSString *)url {
}

- (void)setMerchantId:(__unused NSString *)merc {
}

- (void)collect:(__unused NSString *)sessionId {
}

- (void)setDelegate:(__unused id<DeviceCollectorSDKDelegate>)delegate {
}


@end

#endif