#import "BTThreeDSecureResult.h"
@class BTJSON;

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureResult ()

@property (nonatomic, nullable, readwrite, strong) BTCardNonce *tokenizedCard;

- (instancetype)initWithJSON:(BTJSON *)JSON;

@end

NS_ASSUME_NONNULL_END
