#import "BTSpecHelper.h"

@implementation NSString (Nonce)

- (BOOL)isANonce {
    NSString *nonceRegularExpressionString = @"\\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\\Z";

    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:nonceRegularExpressionString
                                                                      options:0
                                                                        error:&error];
    if (error) {
        NSLog(@"Error parsing regex: %@", error);
        return NO;
    }

    if ([regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0) {
        return YES;
    }

    NSString *tokenizerNonceRegularExpressionString = @"\\Atokencc_[0-9a-z_]+\\Z";
    regex = [[NSRegularExpression alloc] initWithPattern:tokenizerNonceRegularExpressionString
                                                 options:0
                                                   error:&error];
    if (error) {
        NSLog(@"Error parsing regex: %@", error);
        return NO;
    }

    return [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])] > 0;

}

@end
