#import <Foundation/Foundation.h>

@interface BTPaymentApplePayConfiguration : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (id)init __attribute__((unavailable("Please use initWithDictionary:")));

@property (nonatomic, assign, readonly) BOOL enabled;
@property (nonatomic, copy, readonly) NSString *merchantId;

@end
