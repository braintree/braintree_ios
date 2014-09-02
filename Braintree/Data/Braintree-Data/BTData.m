#import "BTData.h"
#import "DeviceCollectorSDK.h"

static NSString *BTDataSharedMerchantId = @"600000";

@interface BTData () <DeviceCollectorSDKDelegate>
@property (nonatomic, copy) NSString *fraudMerchantId;
@property (nonatomic, strong) DeviceCollectorSDK *kount;
@end

@implementation BTData

+ (instancetype)defaultDataForEnvironment:(BTDataEnvironment)environment delegate:(id<BTDataDelegate>)delegate {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    BTData *data = [[BTData alloc] initWithDebugOn:NO];
#pragma clang diagnostic pop
    [data setDelegate:delegate];

    NSString *defaultCollectorUrl;
    switch (environment) {
        case BTDataEnvironmentDevelopment:
            return nil;
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
    [data setCollectorUrl:defaultCollectorUrl];
    [data setFraudMerchantId:BTDataSharedMerchantId];

    return data;
}

- (instancetype)initWithDebugOn:(BOOL)debugLogging {
    self = [super init];
    if (self) {
        self.kount = [[DeviceCollectorSDK alloc] initWithDebugOn:debugLogging];

        NSArray *skipList;
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized && [CLLocationManager locationServicesEnabled]) {
            skipList = @[DC_COLLECTOR_DEVICE_ID];
        } else {
            skipList = @[DC_COLLECTOR_DEVICE_ID, DC_COLLECTOR_GEO_LOCATION];
        }
        [self.kount setSkipList:skipList];
    }
    return self;
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

    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"device_session_id": deviceSessionId, @"fraud_merchant_id": self.fraudMerchantId }
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
    [self.delegate btDataDidStartCollectingData:self];
}

- (void)onCollectorSuccess {
    [self.delegate btDataDidComplete:self];
}

- (void)onCollectorError:(int)errorCode :(NSError *)error {
    [self.delegate btData:self didFailWithErrorCode:errorCode error:error];
}

@end
