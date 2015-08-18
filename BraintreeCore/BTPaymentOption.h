#import <Foundation/Foundation.h>
#import "BTTokenized.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTPaymentOption : NSObject

// @name Built-In Payment Options

+ (instancetype)cards;
+ (instancetype)threeDSecureCards;
+ (instancetype)venmo;
+ (instancetype)coinbase;
+ (instancetype)payPalCheckout;
+ (instancetype)payPalAuthoriztion;
+ (instancetype)applePay;

- (instancetype)initWithLabel:(NSString *)label action:(void (^)(id<BTTokenized> __BT_NULLABLE tokenizedPaymentMethod, NSError * __BT_NULLABLE error))actionBlock NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) NSURL *logoImageURL;
@property (nonatomic, strong) NSArray *mutuallyExclusivePaymentOptions;

@end

BT_ASSUME_NONNULL_END
