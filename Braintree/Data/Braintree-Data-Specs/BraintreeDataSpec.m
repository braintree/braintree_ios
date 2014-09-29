#import "DeviceCollectorSDK.h"
#import "BTData.h"
#import "BTTestClientTokenFactory.h"
#import "BTClientToken+BTPayPal.h"
#import "BTClient+BTPayPal.h"

@interface TestDataDelegate : NSObject <BTDataDelegate>
@property (nonatomic, assign) BOOL didStart;
@property (nonatomic, assign) BOOL didComplete;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) int errorCode;
@end

@implementation TestDataDelegate

- (void)btData:(BTData *)data didFailWithErrorCode:(int)errorCode error:(NSError *)error {
    @throw error;
}

- (void)btDataDidStartCollectingData:(BTData *)data {
    self.didStart = YES;
}

- (void)btDataDidComplete:(BTData *)data {
    self.didComplete = YES;
}

@end

NSString *clientTokenStringFromNSDictionary(NSDictionary *dictionary) {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

SpecBegin(BraintreeData)

__block NSMutableDictionary *baseClientTokenClaims;
__block void (^waitForAssertion)(BOOL (^assertion)(void));

beforeEach(^{
    baseClientTokenClaims = [NSMutableDictionary dictionaryWithDictionary:@{ BTClientTokenKeyAuthorizationFingerprint: @"auth_fingerprint",
                                                                             BTClientTokenKeyClientApiURL: @"http://gateway.example.com/client_api" }];


    waitForAssertion = ^(BOOL (^assertion)(void)){
        for (NSInteger count  = 0; count < 100; count++) {
            if (assertion()) {
                break;
            }
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }

        expect(assertion()).to.beTruthy();
    };

});

__block id mockCLLocationManager;

beforeEach(^{
    mockCLLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
    [[[[mockCLLocationManager stub] andReturnValue:@(NO)] classMethod] locationServicesEnabled];
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
    __block NSMutableArray *arrayToRetainBTDataInstanceDuringAsyncAssertion;
    beforeAll(^{
        arrayToRetainBTDataInstanceDuringAsyncAssertion = [NSMutableArray array];
    });

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

            TestDataDelegate *delegate = [[TestDataDelegate alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            BTData *data = [BTData defaultDataForEnvironment:env delegate:delegate];

            [data collect];
#pragma clang diagnostic pop

            [arrayToRetainBTDataInstanceDuringAsyncAssertion addObject:data];
            expect(delegate.didStart).to.beTruthy();
            expect(delegate.didComplete).will.beTruthy();
        });
    });

    sharedExamplesFor(@"a successful data collector", ^(NSDictionary *testData){
        it([NSString stringWithFormat:@"successfully starts and completes in %@ environment", testData[@"environmentName"]], ^AsyncBlock{
            BTDataEnvironment env = [testData[@"environment"] integerValue];

            baseClientTokenClaims[@"paypal"] = testData[@"paypalConfiguration"];
            baseClientTokenClaims[@"paypalEnabled"] = @YES;

            BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenStringFromNSDictionary(baseClientTokenClaims)];

            TestDataDelegate *delegate = [[TestDataDelegate alloc] init];
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

            [arrayToRetainBTDataInstanceDuringAsyncAssertion addObject:data];

            waitForAssertion(^BOOL{
                return delegate.didStart;
            });

            waitForAssertion(^BOOL{
                return delegate.didComplete;
            });

            done();
        });

        it(@"ignores application correlation id if PayPal is disabled", ^{
            BTDataEnvironment env = [testData[@"environment"] integerValue];

            baseClientTokenClaims[@"paypalEnabled"] = @NO;

            BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenStringFromNSDictionary(baseClientTokenClaims)];

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

            baseClientTokenClaims[@"paypalEnabled"] = @NO;

            BTClient *client = [[BTClient alloc] initWithClientToken:clientTokenStringFromNSDictionary(baseClientTokenClaims)];

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

    itBehavesLike(@"a successful deprecated data collector", @{@"environmentName": @"Sandbox", @"environment": @(BTDataEnvironmentSandbox)});
    itBehavesLike(@"a successful deprecated data collector", @{@"environmentName": @"Production", @"environment": @(BTDataEnvironmentProduction)});

    itBehavesLike(@"a successful data collector", @{ @"environmentName": @"Sandbox",
                                                     @"environment": @(BTDataEnvironmentSandbox),
                                                     @"paypalConfiguration": @{
                                                             @"clientId": NSNull.null,
                                                             @"environment": BTClientTokenPayPalEnvironmentOffline
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
