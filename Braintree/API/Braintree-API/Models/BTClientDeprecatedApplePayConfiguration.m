#import "BTClientDeprecatedApplePayConfiguration.h"
#import "BTLogger_Internal.h"

@implementation BTClientDeprecatedApplePayConfiguration

- (instancetype)initWithConfigurationObject:(id)configurationObject {
    self = [super init];
    if (self) {
        NSString *statusString;
        if ([configurationObject respondsToSelector:@selector(objectForKeyedSubscript:)]) {
            [[BTLogger sharedLogger] warning:@"This Apple Pay configuration is deprecated. Upcoming service changes will disable Apple Pay for this SDK version."];
            if ([configurationObject[@"merchantId"] isKindOfClass:[NSString class]]) {
                _merchantId = [configurationObject[@"merchantId"] copy];
            }
            statusString = configurationObject[@"status"];
            _status = [[self class] statusTypeForString:statusString];
        } else if ([configurationObject isKindOfClass:[NSString class]]) {
            [[BTLogger sharedLogger] warning:@"This Apple Pay configuration is deprecated. Upcoming service changes will disable Apple Pay for this SDK version."];
            statusString = configurationObject;
            _status = [[self class] statusTypeForString:statusString];
            if (_status == BTClientApplePayStatusMock) {
                _merchantId = @"mock-merchant-id";
            }
        } else {
            if (configurationObject != nil) {
                [[BTLogger sharedLogger] error:@"Encountered an unexpected Apple Pay configuration format."];
            }
            statusString = @"off";
            _status = BTClientApplePayStatusOff;
        }
        [[BTLogger sharedLogger] info:@"Using '%@' Apple Pay for merchant '%@'", statusString, _merchantId];
    }
    return self;
}

+ (BTClientApplePayStatus)statusTypeForString:(NSString *)statusString {
    if ([statusString isEqualToString:@"mock"]) {
        return BTClientApplePayStatusMock;
    } else if([statusString isEqualToString:@"production"]) {
        return BTClientApplePayStatusProduction;
    } else {
        return BTClientApplePayStatusOff;
    }
}

@end
