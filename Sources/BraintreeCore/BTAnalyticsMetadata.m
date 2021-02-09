#import "BTAnalyticsMetadata.h"
#import "Braintree-Version.h"
#import "BTKeychain.h"

#import <UIKit/UIKit.h>
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
    [self setObject:[m deviceManufacturer] forKey:@"deviceManufacturer" inDictionary:data];
    [self setObject:[m deviceModel] forKey:@"deviceModel" inDictionary:data];

    [self setObject:[m iosDeviceName] forKey:@"iosDeviceName" inDictionary:data];
    [self setObject:[m iosSystemName] forKey:@"iosSystemName" inDictionary:data];
    [self setObject:[m iosBaseSDK] forKey:@"iosBaseSDK" inDictionary:data];
    [self setObject:[m iosDeploymentTarget] forKey:@"iosDeploymentTarget" inDictionary:data];
    [self setObject:[m iosIdentifierForVendor] forKey:@"iosIdentifierForVendor" inDictionary:data];
    [self setObject:[m iosPackageManager] forKey:@"iosPackageManager" inDictionary:data];
    [self setObject:[m deviceAppGeneratedPersistentUuid] forKey:@"deviceAppGeneratedPersistentUuid" inDictionary:data];
    [self setObject:@([m isSimulator]) forKey:@"isSimulator" inDictionary:data];
    [self setObject:[m deviceScreenOrientation] forKey:@"deviceScreenOrientation" inDictionary:data];
    [self setObject:@([m isVenmoInstalled]) forKey:@"venmoInstalled" inDictionary:data];
    [self setObject:[m dropInVersion] forKey:@"dropinVersion" inDictionary:data];

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
    return UIDevice.currentDevice.systemVersion;
}

- (NSString *)sdkVersion {
    return BRAINTREE_VERSION;
}

- (NSString *)merchantAppId {
    return [NSBundle.mainBundle.infoDictionary objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
}

- (NSString *)merchantAppVersion {
    return [NSBundle.mainBundle.infoDictionary objectForKey:(__bridge NSString *)kCFBundleVersionKey];
}

- (NSString *)merchantAppName {
    return [NSBundle.mainBundle.infoDictionary objectForKey:(__bridge NSString *)kCFBundleNameKey];
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

- (NSString *)iosIdentifierForVendor {
    return UIDevice.currentDevice.identifierForVendor.UUIDString;
}

- (NSString *)iosPackageManager {
#ifdef COCOAPODS
    return @"CocoaPods";
#elif SWIFT_PACKAGE
    return @"Swift Package Manager";
#else
    return @"Carthage or Other";
#endif
}

- (NSString *)iosDeploymentTarget {
    NSString *rawVersionString = NSBundle.mainBundle.infoDictionary[@"MinimumOSVersion"];
    NSArray<NSString *> *rawVersionArray = [rawVersionString componentsSeparatedByString:@"."];
    NSInteger formattedVersionNumber = rawVersionArray[0].integerValue * 10000;
    
    if (rawVersionArray.count > 1) {
        formattedVersionNumber += rawVersionArray[1].integerValue * 100;
    }
    
    return [NSString stringWithFormat:@"%@", @(formattedVersionNumber)];
}

- (NSString *)iosBaseSDK {
    return [@(__IPHONE_OS_VERSION_MAX_ALLOWED) stringValue];
}

- (NSString *)iosDeviceName {
    return UIDevice.currentDevice.name;
}

- (NSString *)iosSystemName {
    return UIDevice.currentDevice.systemName;
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

- (NSString *)deviceScreenOrientation {
    if ([self.class isAppExtension]) {
        return @"AppExtension";
    }
    if ([UIDevice class] == nil) {
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

- (BOOL)isVenmoInstalled {
    if ([self.class isAppExtension]) {
        return NO;
    }

    if (!NSClassFromString(@"BTVenmoDriver")) {
        return NO;
    }
    
    UIApplication *sharedApplication = [UIApplication performSelector:@selector(sharedApplication)];
    static BOOL venmoInstalled;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *venmoURL = [NSURL URLWithString:@"com.venmo.touch.v2://x-callback-url/vzero/auth"];
        venmoInstalled = [sharedApplication canOpenURL:venmoURL];
    });
    return venmoInstalled;
}

- (NSString *)dropInVersion {
    static NSString *dropInVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *localizationBundlePath = [NSBundle.mainBundle pathForResource:@"Braintree-UIKit-Localization"
                                                                         ofType:@"bundle"];
        if (localizationBundlePath) {
            NSBundle *localizationBundle = [NSBundle bundleWithPath:localizationBundlePath];
            // 99.99.99 is the version specified when running the Demo app for this project.
            // We want to ignore it in this case and not return a version.
            if (localizationBundle && ! [localizationBundle.infoDictionary[@"CFBundleShortVersionString"] isEqualToString:@"99.99.99"]) {
                dropInVersion = localizationBundle.infoDictionary[@"CFBundleShortVersionString"];
            }
        }
    });

    return dropInVersion;
}
    
+ (BOOL)isAppExtension {
    NSDictionary *extensionDictionary = NSBundle.mainBundle.infoDictionary[@"NSExtension"];
    return [extensionDictionary isKindOfClass:[NSDictionary class]];
}

@end
