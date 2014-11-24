#import "EXPMatchers+BTBeANonce.h"

EXPMatcherImplementationBegin(beANonce, (void))

prerequisite(^BOOL{
    return [actual isKindOfClass:[NSString class]];
});

match(^BOOL{
    NSString *nonceRegularExpressionString = @"\\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\\Z";

    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:nonceRegularExpressionString
                                                                      options:0
                                                                        error:&error];
    NSAssert(error == nil, @"Error while compiling regular expression pattern \"%@\" (%@)", nonceRegularExpressionString, error);

    return [regex numberOfMatchesInString:actual options:0 range:NSMakeRange(0, [actual length])] > 0;
});


failureMessageForTo(^NSString *{
    return [NSString stringWithFormat:@"expected \"%@\" to look like a nonce, but it did not", actual];
});

failureMessageForNotTo(^NSString *{
    return [NSString stringWithFormat:@"expected \"%@\" not to look like a nonce, but it did", actual];
});

EXPMatcherImplementationEnd
