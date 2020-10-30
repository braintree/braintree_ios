#import <BraintreeThreeDSecure/BTThreeDSecureResult.h>

@class BTJSON;

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureResult ()

@property (nonatomic, nullable, strong, readwrite) BTCardNonce *tokenizedCard;

- (instancetype)initWithJSON:(BTJSON *)JSON;

@end

NS_ASSUME_NONNULL_END
