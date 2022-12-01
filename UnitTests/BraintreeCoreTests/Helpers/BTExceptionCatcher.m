#import "BTExceptionCatcher.h"

// `NSException` is not easily testable in Swift. This is a wrapper around Obj-C try/catch to allow us to test that the error
// is returned as expected. This solution was pulled from here: https://stackoverflow.com/questions/32758811/catching-nsexception-in-swift/36454808#36454808
@implementation BTExceptionCatcher

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        NSMutableDictionary * info = [NSMutableDictionary dictionary];
        [info setValue:exception.reason forKey:@"ExceptionReason"];

        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:info];
        return NO;
    }
}

@end
