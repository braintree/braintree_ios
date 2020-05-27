#import "BTPreferredPaymentMethodsResult.h"
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTPreferredPaymentMethodsResult ()

@property (nonatomic, assign) BOOL isPayPalPreferred;
@property (nonatomic, assign) BOOL isVenmoPreferred;

- (instancetype)initWithJSON:(BTJSON * _Nullable)json venmoInstalled:(BOOL)venmoInstalled;

@end

NS_ASSUME_NONNULL_END
