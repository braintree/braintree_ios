#import "BTMockOpenURLOptions.h"

@implementation BTMockOpenURLOptions

- (instancetype)initWithSourceApplication:(NSString *)sourceApplication {
    if (self = [super init]) {
        _mock = OCMClassMock(UISceneOpenURLOptions.class);
        OCMStub(_mock.sourceApplication).andReturn(sourceApplication);
    }
    return self;
}

@end
