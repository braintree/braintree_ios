#import "BTConfiguration.h"

/// Beta flags
static BOOL venmoBetaFlag = false;

@implementation BTConfiguration

- (instancetype)init {
    @throw [[NSException alloc] initWithName:@"Invalid initializer" reason:@"Use designated initializer" userInfo:nil];
}

- (instancetype)initWithJSON:(BTJSON *)json {
    if (self = [super init]) {
        _json = json;
    }
    return self;
}

+ (BOOL)isBetaEnabledPaymentOption:(NSString*)paymentOption {
    if ([paymentOption.lowercaseString isEqualToString:@"venmo"]) {
        return venmoBetaFlag;
    } else {
        return false;
    }
}

+ (void)setBetaPaymentOption:(NSString*)paymentOption isEnabled:(BOOL)isEnabled {
    if ([paymentOption.lowercaseString isEqualToString:@"venmo"]) {
        venmoBetaFlag = isEnabled;
    }
}


@end
