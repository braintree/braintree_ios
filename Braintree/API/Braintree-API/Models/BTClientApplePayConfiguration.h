#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BTClientApplePayStatusType) {
    BTClientApplePayStatusOff = 0,
    BTClientApplePayStatusMock = 1,
    BTClientApplePayStatusProduction = 2,
};

@interface BTClientApplePayConfiguration : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (id)init __attribute__((unavailable("Please use initWithDictionary:")));

@property (nonatomic, assign, readonly) BTClientApplePayStatusType status;
@property (nonatomic, copy, readonly) NSString *merchantId;

@end
