#import "BTMockOpenURLContext.h"

@implementation BTMockOpenURLContext

- (instancetype)initWithURL:(NSURL *)url options:(BTMockOpenURLOptions *)options{
    if (self = [super init]) {
        _mock = OCMClassMock(UIOpenURLContext.class);
        OCMStub(_mock.URL).andReturn(url);
        OCMStub(_mock.options).andReturn(options);
    }
    return self;
}

@end
