#import "BTDataCollector.h"
#import "DeviceCollectorSDK.h"

@interface BTDataCollector () <DeviceCollectorSDKDelegate>
@property (nonatomic, strong) DeviceCollectorSDK *kount;
@property (nonatomic, assign) BTDataCollectorEnvironment environment;
@property (nonatomic, copy) NSString *fraudMerchantId;
@end

@implementation BTDataCollector

static NSString *BTDataCollectorSharedMerchantId = @"600000";

NSString * const BTDataCollectorKountErrorDomain = @"com.braintreepayments.BTDataCollectorKountErrorDomain";

#pragma mark - Initialization and setup

- (instancetype)initWithEnvironment:(BTDataCollectorEnvironment)environment {
    if (self = [super init]) {
        [self setUpKountWithDebugOn:NO];
        _environment = environment;
        [self setCollectorUrl:[self defaultCollectorURL]];
        [self setFraudMerchantId:BTDataCollectorSharedMerchantId];
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

+ (NSString *)payPalClientMetadataId {
    Class paypalClass = NSClassFromString(@"PayPalOneTouchCore");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (paypalClass && [paypalClass respondsToSelector:@selector(clientMetadataID)]) {
        return [paypalClass performSelector:@selector(clientMetadataID)];
    }
#pragma clang diagnostic pop

    return nil;
}

/// At this time, this method only collects data with Kount. However, it is possible that in the future,
/// we will want to collect data (for card transactions) with PayPal as well. If this becomes the case,
/// we can modify this method to include a clientMetadataID without breaking the public interface.
- (NSString *)collectCardFraudData
{
    return [self collectFraudDataForCard:YES forPayPal:NO];
}

- (NSString *)collectPayPalClientMetadataId
{
    return [self collectFraudDataForCard:NO forPayPal:YES];
}

/// Similar to `collectCardFraudData` but with the addition of the payPalClientMetadataId, if available.
- (NSString *)collectFraudData
{
    return [self collectFraudDataForCard:YES forPayPal:YES];
}

- (NSString *)collectFraudDataForCard:(BOOL)includeCard forPayPal:(BOOL)includePayPal
{
    NSMutableDictionary *dataDictionary = [NSMutableDictionary new];
    if (includeCard) {
        NSString *deviceSessionId = [self sessionId];
        dataDictionary[@"device_session_id"] = deviceSessionId;
        dataDictionary[@"fraud_merchant_id"] = self.fraudMerchantId;
        [self.kount collect:deviceSessionId];
    }
    if (includePayPal) {
        NSString *payPalClientMetadataId = [BTDataCollector payPalClientMetadataId];
        if (payPalClientMetadataId) {
            dataDictionary[@"correlation_id"] = payPalClientMetadataId;
        }
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDictionary options:0 error:&error];
    if (!data) {
        NSLog(@"ERROR: Failed to create deviceData string, error = %@", error);
        return @"";
    }
    
    // If only PayPal fraud is being collected, immediately inform the delegate that collection has
    // finished, since Dyson does not allow us to know when it has officially finished collection.
    if (!includeCard && includePayPal) {
        [self onCollectorSuccess];
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)setCollectorUrl:(NSString *)url{
    [self.kount setCollectorUrl:url];
}

- (void)setFraudMerchantId:(NSString *)fraudMerchantId {
    _fraudMerchantId = fraudMerchantId;
    [self.kount setMerchantId:fraudMerchantId];
}

#pragma mark - Private methods

/// Generates a new session ID
- (NSString *)sessionId {
    return [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (NSString *)defaultCollectorURL {
    NSString *defaultCollectorURL;
    switch (self.environment) {
        case BTDataCollectorEnvironmentDevelopment:
            break;
        case BTDataCollectorEnvironmentQA:
            defaultCollectorURL = @"https://assets.qa.braintreegateway.com/data/logo.htm";
            break;
        case BTDataCollectorEnvironmentSandbox:
            defaultCollectorURL = @"https://assets.braintreegateway.com/sandbox/data/logo.htm";
            break;
        case BTDataCollectorEnvironmentProduction:
            defaultCollectorURL = @"https://assets.braintreegateway.com/data/logo.htm";
            break;
    }
    return defaultCollectorURL;
}

#pragma mark DeviceCollectorSDKDelegate methods

/// The collector has started.
- (void)onCollectorStart {
    if ([self.delegate respondsToSelector:@selector(dataCollectorDidStart:)]) {
        [self.delegate dataCollectorDidStart:self];
    }
}

/// The collector finished successfully.
- (void)onCollectorSuccess {
    if ([self.delegate respondsToSelector:@selector(dataCollectorDidComplete:)]) {
        [self.delegate dataCollectorDidComplete:self];
    }
}

/// An error occurred.
///
/// @param errorCode Error code
/// @param error Triggering error if available
- (void)onCollectorError:(int)errorCode
               withError:(NSError*)error {
    if (error == nil) {
        error = [NSError errorWithDomain:BTDataCollectorKountErrorDomain
                                    code:errorCode
                                userInfo:@{
                                           NSLocalizedDescriptionKey: @"Failed to send data",
                                           NSLocalizedFailureReasonErrorKey: [self failureReasonForKountErrorCode:errorCode]}];
    }

    if ([self.delegate respondsToSelector:@selector(dataCollector:didFailWithError:)]) {
        [self.delegate dataCollector:self didFailWithError:error];
    }
}

- (NSString *)failureReasonForKountErrorCode:(int)errorCode {
    switch (errorCode) {
        case DC_ERR_NONETWORK:
            return @"Network access not available";
        case DC_ERR_INVALID_URL:
            return @"Invalid collector URL";
        case DC_ERR_INVALID_MERCHANT:
            return @"Invalid merchant ID";
        case DC_ERR_INVALID_SESSION:
            return @"Invalid session ID";
        case DC_ERR_VALIDATION_FAILURE:
            return @"Session validation failure";
        default:
            return @"Unknown error";
    }
}

@end
