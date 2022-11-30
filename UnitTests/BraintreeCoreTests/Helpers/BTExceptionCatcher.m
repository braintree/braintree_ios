#import "BTExceptionCatcher.h"

// TODO: add docs for why this is needed
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
