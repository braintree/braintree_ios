#import "BTFraudData.h"
#import "DeviceCollectorSDK.h"

@interface BTFraudData () <DeviceCollectorSDKDelegate>
@property (nonatomic, strong) DeviceCollectorSDK *kount;
@property (nonatomic, assign) BTFraudDataEnvironment environment;
/// The JSON serialized string that contains the merchant ID, session ID, and the PayPal fraud ID (if PayPal is available)
@property (nonatomic, copy) NSString *deviceData;
@property (nonatomic, copy) void (^completionBlock)(NSString *, NSError *);
@end

@implementation BTFraudData

static NSString *BTFraudDataSharedMerchantId = @"600000";


#pragma mark - Initialization and setup


- (instancetype)initWithEnvironment:(BTFraudDataEnvironment)environment {
    if (self = [super init]) {
        [self setUpKountWithDebugOn:NO];
        _environment = environment;
    }
    return self;
}


- (void)setUpKountWithDebugOn:(BOOL)debugLogging {
    self.kount = [[DeviceCollectorSDK alloc] initWithDebugOn:debugLogging];
    [self.kount setDelegate:self];
    
    NSArray *skipList;
    CLAuthorizationStatus locationStatus = [CLLocationManager authorizationStatus];
    if ((locationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || locationStatus == kCLAuthorizationStatusAuthorizedAlways) && [CLLocationManager locationServicesEnabled]) {
        skipList = @[DC_COLLECTOR_DEVICE_ID];
    } else {
        skipList = @[DC_COLLECTOR_DEVICE_ID, DC_COLLECTOR_GEO_LOCATION];
    }
    [self.kount setSkipList:skipList];
}


#pragma mark - Public methods


+ (NSString *)payPalFraudID {
    Class paypalClass = NSClassFromString(@"PayPalOneTouchCore");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (paypalClass && [paypalClass respondsToSelector:@selector(clientMetadataID)]) {
        return [paypalClass performSelector:@selector(clientMetadataID)];
    }
#pragma clang diagnostic pop

    return nil;
}

- (void)collectCardFraudData:(nullable void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock
{
    [self collectCardFraudDataWithMerchantID:BTFraudDataSharedMerchantId
                                collectorURL:[self defaultCollectorURL]
                                  completion:completionBlock];
}

- (void)collectCardFraudDataWithMerchantID:(NSString *)merchantID
                          collectorURL:(NSString *)collectorURL
                            completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completionBlock
{
    if (self.completionBlock != nil) {
        NSLog(@"Fraud data is already being collected");
        if (completionBlock) {
            NSError *error = [NSError errorWithDomain:@"com.braintreepayments.BTFraudDataError"
                                                 code:0
                                             userInfo:@{ NSLocalizedDescriptionKey : @"Fraud data is already being collected" }];
            completionBlock(nil, error);
        }
        return;
    }
    
    self.completionBlock = completionBlock;
    
    NSString *deviceSessionId = [self sessionId];
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithDictionary:@{ @"device_session_id": deviceSessionId,
                                                                                           @"fraud_merchant_id": merchantID
                                                                                           }];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
    if (!data) {
        self.completionBlock(nil, error);
    } else {
        self.deviceData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    [self.kount setMerchantId:merchantID];
    [self.kount setCollectorUrl:collectorURL];
    [self.kount collect:deviceSessionId];
}

- (void)collectFraudData:(nullable void (^)(NSString * _Nullable deviceData, NSError * _Nullable error))completionBlock
{
    [self collectFraudDataWithMerchantID:BTFraudDataSharedMerchantId
                            collectorURL:[self defaultCollectorURL]
                              completion:completionBlock];
}

- (void)collectFraudDataWithMerchantID:(NSString *)merchantID
                          collectorURL:(NSString *)collectorURL
                            completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completionBlock
{
    if (self.completionBlock != nil) {
        NSLog(@"Fraud data is already being collected");
        if (completionBlock) {
            NSError *error = [NSError errorWithDomain:@"com.braintreepayments.BTFraudDataError"
                                                 code:0
                                             userInfo:@{ NSLocalizedDescriptionKey : @"Fraud data is already being collected" }];
            completionBlock(nil, error);
        }
        return;
    }
    
    self.completionBlock = completionBlock;
    
    NSString *deviceSessionId = [self sessionId];
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithDictionary:@{ @"device_session_id": deviceSessionId,
                                                                                           @"fraud_merchant_id": merchantID
                                                                                           }];
    NSString *payPalFraudID = [BTFraudData payPalFraudID];
    if (payPalFraudID) {
        dataDictionary[@"correlation_id"] = payPalFraudID;
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
    if (!data) {
        self.completionBlock(nil, error);
    } else {
        self.deviceData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    [self.kount setMerchantId:merchantID];
    [self.kount setCollectorUrl:collectorURL];
    [self.kount collect:deviceSessionId];
}


#pragma mark - Private methods


/// Generates a new session ID
- (NSString *)sessionId {
    return [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (NSString *)defaultCollectorURL {
    NSString *defaultCollectorURL;
    switch (self.environment) {
        case BTFraudDataEnvironmentDevelopment:
            break;
        case BTFraudDataEnvironmentQA:
            defaultCollectorURL = @"https://assets.qa.braintreegateway.com/data/logo.htm";
            break;
        case BTFraudDataEnvironmentSandbox:
            defaultCollectorURL = @"https://assets.braintreegateway.com/sandbox/data/logo.htm";
            break;
        case BTFraudDataEnvironmentProduction:
            defaultCollectorURL = @"https://assets.braintreegateway.com/data/logo.htm";
            break;
    }
    return defaultCollectorURL;
}


#pragma mark DeviceCollectorSDKDelegate methods

- (void)onCollectorSuccess {
    if (self.completionBlock) self.completionBlock(self.deviceData, nil);
    self.completionBlock = nil;
    self.deviceData = nil;
}

- (void)onCollectorError:(__unused int)errorCode :(NSError *)error {
    if (self.completionBlock) self.completionBlock(nil, error);
    self.completionBlock = nil;
    self.deviceData = nil;
}

@end
