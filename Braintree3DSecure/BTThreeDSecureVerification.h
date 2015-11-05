#import <Foundation/Foundation.h>
#if __has_include("BraintreeCard.h")
#import "BTCard.h"
#import "BTCardNonce.h"
#else
#import <BraintreeCard/BTCard.h>
#import <BraintreeCard/BTCardNonce.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureVerification : NSObject

#pragma mark - Initializers

- (instancetype)initWithCardTokenizationRequest:(BTCard *)cardTokenizationRequest NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithPaymentMethodNonce:(NSString *)paymentMethodNonce NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithTokenizedCard:(BTCardNonce *)tokenizedCard;

- (instancetype)init __attribute__((unavailable("This initializer is not available.")));

#pragma mark - Properties

@property (nonatomic, nullable, strong) NSDecimalNumber *amount;
@property (nonatomic, nullable, copy) NSString *merchantAccountID;

@end

NS_ASSUME_NONNULL_END
