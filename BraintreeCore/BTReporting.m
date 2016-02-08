#import "BTReporting.h"

NSString * const BTCrashReportKey = @"com.braintreepayments.BTCrashReportKey";

@implementation BTReporting

NSUncaughtExceptionHandler *wrappedHandler;

+ (instancetype)sharedInstance {
    static BTReporting *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
        wrappedHandler = NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(&uncaughtExceptionWrapper);
    });

    return instance;
}

void uncaughtExceptionWrapper(NSException *exception) {
    for (NSString *stackSymbol in [exception callStackSymbols]) {
        if ([stackSymbol rangeOfString:@"BT"].location != NSNotFound) {
            [[NSUserDefaults standardUserDefaults] setObject:exception.reason forKey:BTCrashReportKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
    }

    if (wrappedHandler != nil) {
        wrappedHandler(exception);
    }
}

@end
