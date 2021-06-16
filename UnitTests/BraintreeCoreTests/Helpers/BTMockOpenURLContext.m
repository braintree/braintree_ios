#import "BTMockOpenURLContext.h"

@implementation BTMockOpenURLContext

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _mock = OCMClassMock(UIOpenURLContext.class);
        OCMStub(_mock.URL).andReturn(url);
    }
    return self;
}

@end
