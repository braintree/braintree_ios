#import "BTData.h"
#import "DeviceCollectorSDK.h"
#import "PayPalMobile.h"
#import "BTClient+BTPayPal.h"
#import "BTLogger_Internal.h"

static NSString *BTDataSharedMerchantId = @"600000";

@interface BTData () <DeviceCollectorSDKDelegate>
@property (nonatomic, strong) BTClient *client;
@property (nonatomic, copy) NSString *fraudMerchantId;
@property (nonatomic, strong) DeviceCollectorSDK *kount;
@end

@implementation BTData

+ (instancetype)defaultDataForEnvironment:(BTDataEnvironment)environment delegate:(id<BTDataDelegate>)delegate {
    if (environment == BTDataEnvironmentDevelopment) {
        return nil;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BTData *data = [[BTData alloc] initWithDebugOn:NO];
#pragma clang diagnostic pop
    [data setDelegate:delegate];

    [data setupEnvironment:environment];

    return data;
}

- (instancetype)initWithClient:(BTClient *)client environment:(BTDataEnvironment)environment {
    [[BTLogger sharedLogger] log:@"⚠️ The API for -[BTData initWithClient:environment:] is subject to change in the near future."];

    if (!client) {
        return nil;
    }

    if ([client btPayPal_isPayPalEnabled]) {
        NSError *error;
        if (![client btPayPal_preparePayPalMobileWithError:&error]) {
            if (error) {
                [[BTLogger sharedLogger] log:@"BTData could not initialize underlying PayPal SDK. BTData device data will not include PayPal application correlation id."];
            }
        }
    }

    self = [super init];
    if (self) {
        self.client = client;
        [self setupWithDebugOn:NO];
        [self setupEnvironment:environment];
    }
    return self;
}

- (instancetype)initWithDebugOn:(BOOL)debugLogging {
    self = [self init];
    if (self) {
        [self setupWithDebugOn:debugLogging];
    }
    return self;
}

- (void)setupWithDebugOn:(BOOL)debugLogging {
    self.kount = [[DeviceCollectorSDK alloc] initWithDebugOn:debugLogging];

    NSArray *skipList;
    CLAuthorizationStatus locationStatus = [CLLocationManager authorizationStatus];
    if ((locationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || locationStatus == kCLAuthorizationStatusAuthorizedAlways) && [CLLocationManager locationServicesEnabled]) {
        skipList = @[DC_COLLECTOR_DEVICE_ID];
    } else {
        skipList = @[DC_COLLECTOR_DEVICE_ID, DC_COLLECTOR_GEO_LOCATION];
    }
    [self.kount setSkipList:skipList];
}

- (void)setupEnvironment:(BTDataEnvironment)environment {
    NSString *defaultCollectorUrl;
    switch (environment) {
        case BTDataEnvironmentDevelopment:
            break;
        case BTDataEnvironmentQA:
            defaultCollectorUrl = @"https://assets.qa.braintreegateway.com/data/logo.htm";
            break;
        case BTDataEnvironmentSandbox:
            defaultCollectorUrl = @"https://assets.braintreegateway.com/sandbox/data/logo.htm";
            break;
        case BTDataEnvironmentProduction:
            defaultCollectorUrl = @"https://assets.braintreegateway.com/data/logo.htm";
            break;
    }
    [self setCollectorUrl:defaultCollectorUrl];
    [self setFraudMerchantId:BTDataSharedMerchantId];
}

- (void)setCollectorUrl:(NSString *)url{
    [self.kount setCollectorUrl:url];
}

- (void)setFraudMerchantId:(NSString *)fraudMerchantId {
    _fraudMerchantId = fraudMerchantId;
    [self.kount setMerchantId:fraudMerchantId];
}

- (void)setKountMerchantId:(NSString *)kountMerchantId{
    [self setFraudMerchantId:kountMerchantId];
}

- (NSString *)collectDeviceData {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSString *deviceSessionId = [self collect];
#pragma clang diagnostic pop

    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithDictionary:@{ @"device_session_id": deviceSessionId,
                                                                                           @"fraud_merchant_id": self.fraudMerchantId}];
    if (self.client.btPayPal_applicationCorrelationId) {
        dataDictionary[@"correlation_id"] = self.client.btPayPal_applicationCorrelationId;
    }

    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDictionary
                                                   options:0
                                                     error:&error];
    if (error || !data) {
        return nil;
    }

    NSString *dataString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];

    return dataString;
}

- (NSString *)collect {
    NSString *sessionId = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [self collect:sessionId];
    return sessionId;
}

- (void)collect:(NSString *)sessionId{
    [self.kount collect:sessionId];
}

- (void)setDelegate:(id<BTDataDelegate>)delegate {
    _delegate = delegate;
    [self.kount setDelegate:self];
}

#pragma mark DeviceCollectorSDKDelegate methods

- (void)onCollectorStart {
    if ([self.delegate respondsToSelector:@selector(btDataDidStartCollectingData:)]) {
        [self.delegate btDataDidStartCollectingData:self];
    }
}

- (void)onCollectorSuccess {
    if ([self.delegate respondsToSelector:@selector(btDataDidComplete:)]) {
        [self.delegate btDataDidComplete:self];
    }
}

- (void)onCollectorError:(int)errorCode :(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(btData:didFailWithErrorCode:error:)]) {
        [self.delegate btData:self didFailWithErrorCode:errorCode error:error];
    }
}

@end
