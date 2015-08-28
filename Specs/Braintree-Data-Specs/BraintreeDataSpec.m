#import "DeviceCollectorSDK.h"
#import "BTData.h"
#import "BTClientSpecHelper.h"
#import "BTTestClientTokenFactory.h"
#import "BTClientToken.h"
#import "BTConfiguration.h"
#import "BTClient+BTPayPal.h"

@interface TestDataDelegate : NSObject <BTDataDelegate>
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) int errorCode;
@property (nonatomic, copy) void (^didStartBlock)(void);
@property (nonatomic, copy) void (^didCompleteBlock)(void);
@end

@implementation TestDataDelegate

- (instancetype)initWithDidStart:(void (^)(void))didStartBlock
                     didComplete:(void (^)(void))didCompleteBlock {
    if ((self = [super init])) {
        self.didStartBlock = didStartBlock;
        self.didCompleteBlock = didCompleteBlock;
    }
    return self;
}

- (void)btData:(BTData *)data didFailWithErrorCode:(int)errorCode error:(NSError *)error {
    @throw error;
}

- (void)btDataDidStartCollectingData:(BTData *)data {
    if (self.didStartBlock) self.didStartBlock();
}

- (void)btDataDidComplete:(BTData *)data {
    if (self.didCompleteBlock) self.didCompleteBlock();
}
@end

NSString *clientTokenStringFromNSDictionary(NSDictionary *dictionary) {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return [data base64EncodedStringWithOptions:0];
}

SpecBegin(BraintreeData)

__block id mockCLLocationManager;

beforeEach(^{
    mockCLLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[[[mockCLLocationManager stub] andReturnValue:@(NO)] classMethod] locationServicesEnabled];
#pragma clang diagnostic pop
});

afterEach(^{
    [mockCLLocationManager stopMocking];
});

describe(@"Kount DeviceCollectorSDK", ^{
    it(@"should initialize successfully", ^{
        DeviceCollectorSDK *deviceKollector = [[DeviceCollectorSDK alloc] initWithDebugOn:NO];

        expect(deviceKollector).to.beKindOf([DeviceCollectorSDK class]);
    });
});

describe(@"defaultDataForEnvironment:delegate:", ^{
    sharedExamplesFor(@"a no-op data collector", ^(NSDictionary *testData) {
        it(@"successfully starts and completes", ^{

            BTDataEnvironment env = [testData[@"environment"] integerValue];

            TestDataDelegate *delegate = [[TestDataDelegate alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            BTData *data = [BTData defaultDataForEnvironment:env delegate:delegate];
#pragma clang diagnostic pop

            expect(data).to.beNil();
        });
    });

    sharedExamplesFor(@"a deprecated successful data collector", ^(NSDictionary *testData) {
        it([NSString stringWithFormat:@"successfully starts and completes in %@ environment", testData[@"environmentName"]], ^{
            BTDataEnvironment env = [testData[@"environment"] integerValue];

            XCTestExpectation *didStartExpectation = [self expectationWithDescription:@"didStart"];
            XCTestExpectation *didCompleteExpectation = [self expectationWithDescription:@"didComplete"];
            
            TestDataDelegate *delegate = [[TestDataDelegate alloc] initWithDidStart:^{
                [didStartExpectation fulfill];
            } didComplete:^{
                [didCompleteExpectation fulfill];
            }];
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            BTData *data = [BTData defaultDataForEnvironment:env delegate:delegate];

            [data collect];
#pragma clang diagnostic pop

            [self waitForExpectationsWithTimeout:10 handler:nil];
        });
    });

    sharedExamplesFor(@"a successful data collector", ^(NSDictionary *testData){
        it([NSString stringWithFormat:@"successfully starts and completes in %@ environment", testData[@"environmentName"]], ^{
            BTDataEnvironment env = [testData[@"environment"] integerValue];
            
            BTClient *client = [BTClientSpecHelper asyncClientForTestCase:self withOverrides:@{ BTConfigurationKeyPayPal: testData[@"paypalConfiguration"], BTConfigurationKeyPayPalEnabled: @YES }];

            XCTestExpectation *didStartExpectation = [self expectationWithDescription:@"didStart"];
            XCTestExpectation *didCompleteExpectation = [self expectationWithDescription:@"didComplete"];
            
            TestDataDelegate *delegate = [[TestDataDelegate alloc] initWithDidStart:^{
                [didStartExpectation fulfill];
            } didComplete:^{
                [didCompleteExpectation fulfill];
            }];
            BTData *data = [[BTData alloc] initWithClient:client environment:env];
            data.delegate = delegate;
            [data setFraudMerchantId:@"600000"];
            
            NSString *deviceDataString = [data collectDeviceData];
            
            NSDictionary *deviceDataDictionary = [NSJSONSerialization JSONObjectWithData:[deviceDataString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                 options:0
                                                                                   error:NULL];
            
            expect(deviceDataDictionary[@"fraud_merchant_id"]).to.equal(@"600000");
            expect(deviceDataDictionary[@"device_session_id"]).to.haveCountOf(32);
            
            if ([testData[@"shouldIncludeCorrelationId"] boolValue]) {
                expect(deviceDataDictionary[@"correlation_id"]).to.haveCountOf(32);
            } else {
                expect(deviceDataDictionary[@"correlation_id"]).to.beNil();
            }
            
            [self waitForExpectationsWithTimeout:10 handler:nil];
        });

        it(@"ignores application correlation id if PayPal is disabled", ^{
            BTDataEnvironment env = [testData[@"environment"] integerValue];

            BTClient *client = [BTClientSpecHelper asyncClientForTestCase:self withOverrides:@{ BTConfigurationKeyPayPalEnabled: @NO, BTConfigurationKeyPayPal: [NSNull null] }];

            BTData *data = [[BTData alloc] initWithClient:client environment:env];
            [data setFraudMerchantId:@"600000"];

            NSString *deviceDataString = [data collectDeviceData];

            NSDictionary *deviceDataDictionary = [NSJSONSerialization JSONObjectWithData:[deviceDataString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                 options:0
                                                                                   error:NULL];

            expect(deviceDataDictionary[@"correlation_id"]).to.beNil();
        });

        it(@"ignores application correlation id if PayPal preconnect fails", ^{
            BTDataEnvironment env = [testData[@"environment"] integerValue];

            BTClient *client = [BTClientSpecHelper asyncClientForTestCase:self withOverrides:@{ BTConfigurationKeyPayPalEnabled: @NO, BTConfigurationKeyPayPal: [NSNull null] }];

            id stubClient = [OCMockObject partialMockForObject:client];
            [[[stubClient stub] andReturnValue:@NO] btPayPal_preparePayPalMobileWithError:NULL];
            [[[stubClient stub] andReturn:nil] btPayPal_applicationCorrelationId];

            BTData *data = [[BTData alloc] initWithClient:client environment:env];
            [data setFraudMerchantId:@"600000"];

            NSString *deviceDataString = [data collectDeviceData];

            NSDictionary *deviceDataDictionary = [NSJSONSerialization JSONObjectWithData:[deviceDataString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                 options:0
                                                                                   error:NULL];

            expect(deviceDataDictionary).notTo.contain(@"correlation_id");
        });

        it(@"returns nil if BTClient is nil", ^{
            BTData *data = [[BTData alloc] initWithClient:nil environment:BTDataEnvironmentProduction];
            expect(data).to.beNil();
        });
    });

    itBehavesLike(@"a deprecated successful data collector", @{@"environmentName": @"Sandbox", @"environment": @(BTDataEnvironmentSandbox)});
    itBehavesLike(@"a deprecated successful data collector", @{@"environmentName": @"Production", @"environment": @(BTDataEnvironmentProduction)});

    itBehavesLike(@"a successful data collector", @{ @"environmentName": @"Sandbox",
                                                     @"environment": @(BTDataEnvironmentSandbox),
                                                     @"paypalConfiguration": @{
                                                             @"clientId": NSNull.null,
                                                             @"environment": BTConfigurationPayPalEnvironmentOffline
                                                             },
                                                     @"shouldIncludeCorrelationId": @NO
                                                     });
    itBehavesLike(@"a successful data collector", @{@"environmentName": @"Production",
                                                    @"environment": @(BTDataEnvironmentProduction),
                                                    @"paypalConfiguration": @{
                                                            @"clientId": @"ARKrYRDh3AGXDzW7sO_3bSkq-U1C7HG_uWNC-z57LjYSDNUOSaOtIa9q6VpW",
                                                            @"environment": @"live"
                                                            },
                                                    @"shouldIncludeCorrelationId": @YES
                                                    });
    itBehavesLike(@"a no-op data collector", @{@"environmentName": @"Development", @"environment": @(BTDataEnvironmentDevelopment)});
});

SpecEnd
