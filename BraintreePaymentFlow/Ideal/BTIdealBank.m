#import "BTIdealBank.h"

@implementation BTIdealBank

- (instancetype)initWithCountryCode:(NSString *)countryCode issuerId:(NSString *)issuerId name:(NSString *)name imageUrl:(NSString *)imageUrl {
    if (self = [self init]) {
        _countryCode = countryCode;
        _issuerId = issuerId;
        _name = name;
        _imageUrl = imageUrl;
    }
    return self;
}

@end
