#import "BTPreferredPaymentMethodsResult.h"
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTPreferredPaymentMethodsResult ()

@property (nonatomic, assign) BOOL isPayPalPreferred;

- (instancetype)initWithJSON:(BTJSON * _Nullable)json;

@end

NS_ASSUME_NONNULL_END
