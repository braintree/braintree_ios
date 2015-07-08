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
