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
});

SpecEnd
