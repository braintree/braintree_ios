#import "BTSpecHelper.h"

#ifdef DEBUG
BTTestMode_t BTTestMode = BTTestModeDebug;
#else
BTTestMode_t BTTestMode = BTTestModeRelease;
#endif

void wait_for_potential_async_exceptions(void (^done)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        done();
    });
}

BOOL isANonce(NSString *nonce) {
    NSString *nonceRegularExpressionString = @"\\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\\Z";

    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:nonceRegularExpressionString
                                                                      options:0
                                                                        error:&error];
    if (error) {
        NSLog(@"Error parsing regex: %@", error);
        return NO;
    }

    return [regex numberOfMatchesInString:nonce options:0 range:NSMakeRange(0, [nonce length])] > 0;
}
