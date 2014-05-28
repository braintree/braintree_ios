#import "EXPMatchers+BTDeepEquals.h"
#import "EXPMatcherHelpers.h"

EXPMatcherImplementationBegin(_deepEqual, (NSDictionary *expected)) {
    prerequisite(^BOOL{
        return ([actual isKindOfClass:[NSDictionary class]] && [expected isKindOfClass:[NSDictionary class]]);
    });

    match(^BOOL{
        return ((actual == expected) || [actual isEqualToDictionary:expected]);
    });

    failureMessageForTo(^NSString *{
        return [NSString stringWithFormat:@"deep equals expected: %@, got: %@", EXPDescribeObject(expected), EXPDescribeObject(actual)];
    });

    failureMessageForNotTo(^NSString *{
        return [NSString stringWithFormat:@"deep equals expected: not %@, got: %@", EXPDescribeObject(expected), EXPDescribeObject(actual)];
    });
}
EXPMatcherImplementationEnd
