#import "DeviceCollectorSDK.h"
#import "BTData.h"

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

SpecBegin(BraintreeData)

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
            BTData *data = [BTData defaultDataForEnvironment:env delegate:delegate];
            [arrayToRetainBTDataInstanceDuringAsyncAssertion addObject:data];
            [data collect];
            expect(delegate.didStart).to.beFalsy();
            expect(delegate.didComplete).will.beFalsy();
        });
    });

    sharedExamplesFor(@"a successful data collector", ^(NSDictionary *testData) {
        it([NSString stringWithFormat:@"successfully starts and completes in %@ environment", testData[@"environmentName"]], ^{
            BTDataEnvironment env = [testData[@"environment"] integerValue];

            TestDataDelegate *delegate = [[TestDataDelegate alloc] init];
            BTData *data = [BTData defaultDataForEnvironment:env delegate:delegate];
            [data collect];
            [arrayToRetainBTDataInstanceDuringAsyncAssertion addObject:data];
            expect(delegate.didStart).to.beTruthy();
            expect(delegate.didComplete).will.beTruthy();
        });
    });

    itBehavesLike(@"a successful data collector", @{@"environmentName": @"QA", @"environment": @(BTDataEnvironmentQA)});
    itBehavesLike(@"a successful data collector", @{@"environmentName": @"Sandbox", @"environment": @(BTDataEnvironmentSandbox)});
    itBehavesLike(@"a successful data collector", @{@"environmentName": @"Production", @"environment": @(BTDataEnvironmentProduction)});
    itBehavesLike(@"a no-op data collector@", @{@"environmentName": @"Development", @"environment": @(BTDataEnvironmentDevelopment)});


    describe(@"collect with location services enabled", ^{
        it(@"allows Kount to access GEO_LOCATION", ^{
            // Enable location services
            [[[[mockCLLocationManager stub] andReturnValue:@(YES)] classMethod] locationServicesEnabled];
            [[[[mockCLLocationManager stub] andReturnValue:@(kCLAuthorizationStatusAuthorized)] classMethod] authorizationStatus];

            // Stub out DeviceColectorSDK (initialized in -[BTData initWithDebugOn:])
            id mockKount = [OCMockObject mockForClass:[DeviceCollectorSDK class]];
            [[[[mockKount stub] andReturn:mockKount] classMethod] alloc];
            mockKount = [[[mockKount stub] andReturn:mockKount] initWithDebugOn:OCMOCK_ANY];

            // Assert that the skip list does NOT include GEO_LOCATION
            [[mockKount expect] setSkipList:[OCMArg checkWithBlock:^BOOL(id obj) {
                NSArray *skipList = obj;
                return [skipList indexOfObject:DC_COLLECTOR_GEO_LOCATION] == NSNotFound;
            }]];

            [mockKount verify];
            [mockKount stopMocking];
        });
    });
});

SpecEnd
