#import "BTData.h"
#import "DeviceCollectorSDK.h"

static NSString *BTDataSharedMerchantId = @"600000";

@interface BTData () <DeviceCollectorSDKDelegate>
@property (nonatomic, strong) DeviceCollectorSDK *kount;
@end

@implementation BTData

+ (instancetype)defaultDataForEnvironment:(BTDataEnvironment)environment delegate:(id<BTDataDelegate>)delegate {
    BTData *data = [[BTData alloc] initWithDebugOn:NO];
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
    [data setKountMerchantId:BTDataSharedMerchantId];

    return data;
}

- (instancetype)initWithDebugOn:(BOOL)debugLogging {
    self = [super init];
    if (self) {
        self.kount = [[DeviceCollectorSDK alloc] initWithDebugOn:debugLogging];

        NSArray *skipList;
        if ([CLLocationManager locationServicesEnabled]) {
            skipList = @[DC_COLLECTOR_DEVICE_ID, DC_COLLECTOR_GEO_LOCATION];
        } else {
            skipList = @[DC_COLLECTOR_DEVICE_ID];
        }
        [self.kount setSkipList:skipList];
    }
    return self;
}

- (void)setCollectorUrl:(NSString *)url{
    [self.kount setCollectorUrl:url];
}

- (void)setKountMerchantId:(NSString *)merc{
    [self.kount setMerchantId:merc];
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
