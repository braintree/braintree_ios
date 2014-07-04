#import "BTAnalyticsMetaData.h"
#import "BTClient.h"

#import "BTKeychain.h"
#import "BTReachability.h"
#import <CoreLocation/CoreLocation.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

@implementation BTAnalyticsMetadata

+ (NSDictionary *)metadata {
    BTAnalyticsMetadata *m = [[BTAnalyticsMetadata alloc] init];

    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:16];

    [self setObject:[m platform] forKey:@"platform" inDictionary:data];
    [self setObject:[m platformVersion] forKey:@"platformVersion" inDictionary:data];
    [self setObject:[m sdkVersion] forKey:@"sdkVersion" inDictionary:data];
    [self setObject:[m merchantAppId] forKey:@"merchantAppId" inDictionary:data];
    [self setObject:[m merchantAppName] forKey:@"merchantAppName" inDictionary:data];
    [self setObject:[m merchantAppVersion] forKey:@"merchantAppVersion" inDictionary:data];
    [self setObject:@([m deviceRooted]) forKey:@"deviceRooted" inDictionary:data];
    [self setObject:[m deviceManufacturer] forKey:@"deviceManufacturer" inDictionary:data];
    [self setObject:[m deviceModel] forKey:@"deviceModel" inDictionary:data];
    [self setObject:[m deviceNetworkType] forKey:@"deviceNetworkType" inDictionary:data];
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [self setObject:@([m deviceLocationLatitude]) forKey:@"deviceLocationLatitude" inDictionary:data];
        [self setObject:@([m deviceLocationLongitude]) forKey:@"deviceLocationLongitude" inDictionary:data];
    }
    [self setObject:[m iosIdentifierForVendor] forKey:@"iosIdentifierForVendor" inDictionary:data];
    [self setObject:[m deviceAppGeneratedPersistentUuid] forKey:@"deviceAppGeneratedPersistentUuid" inDictionary:data];
    [self setObject:@([m isSimulator]) forKey:@"isSimulator" inDictionary:data];
    [self setObject:[m deviceScreenOrientation] forKey:@"deviceScreenOrientation" inDictionary:data];
    [self setObject:[m userInterfaceOrientation] forKey:@"userInterfaceOrientation" inDictionary:data];

    return [NSDictionary dictionaryWithDictionary:data];
}

+ (void)setObject:(id)object forKey:(id<NSCopying>)aKey inDictionary:(NSMutableDictionary *)dictionary {
    if (object) {
        [dictionary setObject:object forKey:aKey];
    }
}

#pragma mark Metadata Factors

- (NSString *)platform {
    return @"iOS";
}

- (NSString *)platformVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)sdkVersion {
    return [BTClient libraryVersion];
}

- (NSString *)merchantAppId {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
}

- (NSString *)merchantAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey];
}

- (NSString *)merchantAppName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleNameKey];
}

- (BOOL)deviceRooted {
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    BOOL isJailbroken = system(NULL) == 1;

    return isJailbroken;
#endif
}

- (NSString *)deviceManufacturer {
    return @"Apple";
}

- (NSString *)deviceModel {
    struct utsname systemInfo;

    uname(&systemInfo);

    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];


    return code;
}

- (NSString *)deviceNetworkType {
    @try {
        BTNetworkStatus networkStatus = [[BTReachability reachabilityForLocalWiFi] currentReachabilityStatus];
        switch (networkStatus) {
            case BTReachableViaWWAN:
                return @"cellular";
            case BTReachableViaWiFi:
                return @"wifi";
            case BTNotReachable:
                return @"unknown";
            default:
                break;
        }
    } @catch (NSException *e) {
        return nil;
    }
    return nil;
}

- (CLLocationDegrees)deviceLocationLatitude {
    return [[[[CLLocationManager alloc] init] location] coordinate].latitude;
}

- (CLLocationDegrees)deviceLocationLongitude {
    return [[[[CLLocationManager alloc] init] location] coordinate].longitude;
}

- (NSString *)iosIdentifierForVendor {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString *)deviceAppGeneratedPersistentUuid {
    @try {
        static NSString *deviceAppGeneratedPersistentUuidKeychainKey = @"deviceAppGeneratedPersistentUuid";
        NSString *savedIdentifier = [BTKeychain stringForKey:deviceAppGeneratedPersistentUuidKeychainKey];
        if (savedIdentifier.length == 0) {
            savedIdentifier = [[NSUUID UUID] UUIDString];
            BOOL setDidSucceed = [BTKeychain setString:savedIdentifier
                                                forKey:deviceAppGeneratedPersistentUuidKeychainKey];
            if (!setDidSucceed) {
                return nil;
            }
        }
        return savedIdentifier;
    } @catch (NSException *exception) {
        return nil;
    }
}

- (BOOL)isSimulator {
    return TARGET_IPHONE_SIMULATOR;
}

- (NSString *)userInterfaceOrientation {
    if ([UIApplication class] == nil) {
        return nil;
    }

    UIInterfaceOrientation deviceOrientation = [[[[UIApplication sharedApplication] keyWindow] rootViewController] interfaceOrientation];

    switch (deviceOrientation) {
        case UIInterfaceOrientationPortrait:
            return @"Portrait";
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"PortraitUpsideDown";
        case UIInterfaceOrientationLandscapeLeft:
            return @"LandscapeLeft";
        case UIInterfaceOrientationLandscapeRight:
            return @"LandscapeRight";
        default:
            return @"Unknown";
    }
}

- (NSString *)deviceScreenOrientation {
    if ([UIApplication class] == nil) {
        return nil;
    }

    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationFaceUp:
            return @"FaceUp";
        case UIDeviceOrientationFaceDown:
            return @"FaceDown";
        case UIDeviceOrientationPortrait:
            return @"Portrait";
        case UIDeviceOrientationPortraitUpsideDown:
            return @"PortraitUpsideDown";
        case UIDeviceOrientationLandscapeLeft:
            return @"LandscapeLeft";
        case UIDeviceOrientationLandscapeRight:
            return @"LandscapeRight";
        default:
            return @"Unknown";
    }
}


@end
