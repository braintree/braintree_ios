#import <Foundation/Foundation.h>
#import "BTCardTokenizationRequest.h"
#import "BTTokenizedCard.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureVerification : NSObject

- (instancetype)initWithCardTokenizationRequest:(BTCardTokenizationRequest *)cardTokenizationRequest NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPaymentMethodNonce:(NSString *)paymentMethodNonce NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTokenizedCard:(BTTokenizedCard *)tokenizedCard;

@property (nonatomic, nullable, strong) NSDecimalNumber *amount;
@property (nonatomic, nullable, copy) NSString *merchantAccountID;

@end

BT_ASSUME_NONNULL_END
