#import "DeviceCollectorSDK.h"


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

SpecEnd
