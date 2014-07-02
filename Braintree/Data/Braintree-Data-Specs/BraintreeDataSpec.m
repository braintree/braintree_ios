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

describe(@"DeviceCollectorSDK", ^{

#ifdef __LP64__
    it(@"fails to initialize on 64-bit architectures", ^{
        DeviceCollectorSDK *deviceKollector = [[DeviceCollectorSDK alloc] initWithDebugOn:NO];

        expect(deviceKollector).to.beNil();

    });

    it(@"NOOPs all method calls on 64-bit architectures", ^{
        DeviceCollectorSDK *deviceKollector = [[DeviceCollectorSDK alloc] initWithDebugOn:NO];
        expect(^{
            [deviceKollector collect:@"FooBar"];
        }).notTo.raiseAny();
    });
#endif

#ifndef __LP64__
    it(@"should initialize on non 64-bit architectures", ^{
        DeviceCollectorSDK *deviceKollector = [[DeviceCollectorSDK alloc] initWithDebugOn:NO];

        expect(deviceKollector).to.beKindOf([DeviceCollectorSDK class]);
    });
#endif
});

describe(@"defaultDataForEnvironment:delegate:", ^{
    __block NSMutableArray *array;
    beforeAll(^{
        array = [NSMutableArray array];
    });

    sharedExamplesFor(@"a no-op data collector", ^(NSDictionary *testData) {
        it(@"successfully starts and completes", ^{

            BTDataEnvironment env = [testData[@"environment"] integerValue];

            TestDataDelegate *delegate = [[TestDataDelegate alloc] init];
            BTData *data = [BTData defaultDataForEnvironment:env delegate:delegate];
            [data collect];
            expect(delegate.didStart).to.beFalsy();
            expect(delegate.didComplete).will.beFalsy();
        });
    });

    sharedExamplesFor(@"a successful data collector", ^(NSDictionary *testData) {
#ifdef __LP64__
        it([NSString stringWithFormat:@"does nothing in %d environments (on 64-bit architectures)", [testData[@"environment"] intValue]], ^{
            BTDataEnvironment env = [testData[@"environment"] integerValue];

            TestDataDelegate *delegate = [[TestDataDelegate alloc] init];
            BTData *data = [BTData defaultDataForEnvironment:env delegate:delegate];
            [data collect];
            [array addObject:data];
            expect(delegate.didStart).to.beFalsy();
            expect(delegate.didComplete).will.beFalsy();
        });
#else
        it([NSString stringWithFormat:@"successfully starts and completes in %d environment (on 32-bit architectures)", [testData[@"environment"] intValue]], ^{
            BTDataEnvironment env = [testData[@"environment"] integerValue];

            TestDataDelegate *delegate = [[TestDataDelegate alloc] init];
            BTData *data = [BTData defaultDataForEnvironment:env delegate:delegate];
            [data collect];
            [array addObject:data];
            expect(delegate.didStart).to.beTruthy();
            expect(delegate.didComplete).will.beTruthy();
        });
#endif
    });

    itBehavesLike(@"a successful data collector", @{@"environment": @(BTDataEnvironmentQA)});
    itBehavesLike(@"a successful data collector", @{@"environment": @(BTDataEnvironmentSandbox)});
    itBehavesLike(@"a successful data collector", @{@"environment": @(BTDataEnvironmentProduction)});
    itBehavesLike(@"a no-op data collector@", @{@"environment": @(BTDataEnvironmentDevelopment)});
});

SpecEnd
