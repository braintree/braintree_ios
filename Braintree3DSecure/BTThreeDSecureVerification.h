#import <Foundation/Foundation.h>
#import "BTCard.h"
#import "BTTokenizedCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureVerification : NSObject

#pragma mark - Initializers

- (instancetype)initWithCardTokenizationRequest:(BTCard *)cardTokenizationRequest NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithPaymentMethodNonce:(NSString *)paymentMethodNonce NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithTokenizedCard:(BTTokenizedCard *)tokenizedCard;

- (instancetype)init __attribute__((unavailable("This initializer is not available.")));

#pragma mark - Properties

@property (nonatomic, nullable, strong) NSDecimalNumber *amount;
@property (nonatomic, nullable, copy) NSString *merchantAccountID;

@end

NS_ASSUME_NONNULL_END
