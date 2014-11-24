#import "EXPMatchers+BTMatches.h"

EXPMatcherImplementationBegin(match, (id pattern))

prerequisite(^BOOL{
    return [actual isKindOfClass:[NSString class]] && ([pattern isKindOfClass:[NSString class]] || [pattern isKindOfClass:[NSRegularExpression class]]);
});

match(^BOOL{
    NSRegularExpression *regex;
    if ([pattern isKindOfClass:[NSRegularExpression class]]) {
        regex = pattern;
    } else  {
        NSError *error;
        regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&error];
        NSAssert(error == nil, @"Error while compiling regular expression pattern \"%@\" (%@)", pattern, error);
    }

    return [regex numberOfMatchesInString:actual options:0 range:NSMakeRange(0, [actual length])] > 0;
});

failureMessageForTo(^NSString *{
    return [NSString stringWithFormat:@"expected \"%@\" to match regex pattern /%@/, but it did not", actual, pattern];
});

failureMessageForNotTo(^NSString *{
    return [NSString stringWithFormat:@"expected \"%@\" not to match regex pattern /%@/, but it did", actual, pattern];
});

EXPMatcherImplementationEnd
