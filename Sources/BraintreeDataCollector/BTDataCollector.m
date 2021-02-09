#import "BTDataCollector_Internal.h"
#import "kDataCollector.h"
#import <CoreLocation/CoreLocation.h>

#if __has_include(<Braintree/BraintreeDataCollector.h>)
#import <Braintree/BTConfiguration+DataCollector.h>
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeDataCollector/BTConfiguration+DataCollector.h>
#import <BraintreeCore/BraintreeCore.h>
#endif

typedef NS_ENUM(NSInteger, BTDataCollectorEnvironment) {
    /// Development
    BTDataCollectorEnvironmentDevelopment,

    /// QA
    BTDataCollectorEnvironmentQA,

    /// Sandbox
    BTDataCollectorEnvironmentSandbox,

    /// Production
    BTDataCollectorEnvironmentProduction
};

@interface BTDataCollector ()

@property (nonatomic, copy) NSString *fraudMerchantID;
@property (nonatomic, copy) BTAPIClient *apiClient;

@end

@implementation BTDataCollector

static Class PayPalDataCollectorClass;

#pragma mark - Initialization and setup

+ (void)load {
    if (self == [BTDataCollector class]) {
        PayPalDataCollectorClass = NSClassFromString(@"PayPalDataCollector.PPDataCollector") ?: NSClassFromString(@"Braintree.PPDataCollector");
    }
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        [self setUpKountWithDebugOn:NO];
        _apiClient = apiClient;
    }
    
    return self;
}

- (void)setUpKountWithDebugOn:(BOOL)debugLogging {
    self.kount = [KDataCollector sharedCollector];
    self.kount.debug = debugLogging;

    CLAuthorizationStatus locationStatus = kCLAuthorizationStatusNotDetermined;
    if (@available(iOS 14, *)) {
        locationStatus = [CLLocationManager new].authorizationStatus;
    } else {
        locationStatus = [CLLocationManager authorizationStatus];
    }

    if ((locationStatus != kCLAuthorizationStatusAuthorizedWhenInUse && locationStatus != kCLAuthorizationStatusAuthorizedAlways) || ![CLLocationManager locationServicesEnabled]) {
        self.kount.locationCollectorConfig = KLocationCollectorConfigSkip;
    }
}

#pragma mark - Accessors

- (void)setCollectorEnvironment:(KEnvironment)environment {
    self.kount.environment = environment;
}

- (void)setFraudMerchantID:(NSString *)fraudMerchantID {
    _fraudMerchantID = fraudMerchantID;
    self.kount.merchantID = [fraudMerchantID integerValue];
}

#pragma mark - Public methods

- (void)collectDeviceData:(void (^)(NSString * _Nonnull))completion {
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable __unused _) {
        NSMutableDictionary *dataDictionary = [NSMutableDictionary new];

        dispatch_group_t collectorDispatchGroup = dispatch_group_create();

        if (configuration.isKountEnabled) {
            BTDataCollectorEnvironment btEnvironment = [self environmentFromString:configuration.environment];
            [self setCollectorEnvironment:[self collectorEnvironment:btEnvironment]];

            NSString *merchantID = self.fraudMerchantID ?: [configuration kountMerchantID];
            self.kount.merchantID = [merchantID integerValue];

            NSString *deviceSessionID = [self sessionID];
            dataDictionary[@"device_session_id"] = deviceSessionID;
            dataDictionary[@"fraud_merchant_id"] = merchantID;
            dispatch_group_enter(collectorDispatchGroup);
            [self.kount collectForSession:deviceSessionID completion:^(__unused NSString * _Nonnull sessionID, __unused BOOL success, __unused NSError * _Nullable error) {
                dispatch_group_leave(collectorDispatchGroup);
            }];
        }
        
        NSString *payPalClientMetadataID = [BTDataCollector generatePayPalClientMetadataID];
        if (payPalClientMetadataID) {
            dataDictionary[@"correlation_id"] = payPalClientMetadataID;
        }

        dispatch_group_notify(collectorDispatchGroup, dispatch_get_main_queue(), ^{
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
            // Defensive check: JSON serialization should never fail
            if (!data) {
                NSLog(@"ERROR: Failed to create deviceData string, error = %@", error);
                if (completion) {
                    completion(@"");
                }
                return;
            }
            NSString *deviceData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if (completion) {
                completion(deviceData);
            }
        });
    }];
}

#pragma mark - Helper methods

+ (NSString *)generatePayPalClientMetadataID {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (PayPalDataCollectorClass && [PayPalDataCollectorClass respondsToSelector:@selector(generateClientMetadataID)]) {
        return [PayPalDataCollectorClass performSelector:@selector(generateClientMetadataID)];
    }
#pragma clang diagnostic pop
    
    return nil;
}

/// Generates a new session ID
- (NSString *)sessionID {
    return [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (BTDataCollectorEnvironment)environmentFromString:(NSString *)environment {
    if ([environment isEqualToString:@"production"]) {
        return BTDataCollectorEnvironmentProduction;
    } else if ([environment isEqualToString:@"sandbox"]) {
        return BTDataCollectorEnvironmentSandbox;
    } else if ([environment isEqualToString:@"qa"]) {
        return BTDataCollectorEnvironmentQA;
    } else {
        return BTDataCollectorEnvironmentDevelopment;
    }
}

- (KEnvironment)collectorEnvironment:(BTDataCollectorEnvironment)environment {
    switch (environment) {
        case BTDataCollectorEnvironmentProduction:
            return KEnvironmentProduction;
        default:
            return KEnvironmentTest;
    }
}

@end
