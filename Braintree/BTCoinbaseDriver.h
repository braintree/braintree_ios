#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTConfiguration.h"
#import "BTTokenizedCoinbaseAccount.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTCoinbaseDriver : NSObject

- (instancetype)initWithConfiguration:(BTConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

- (void)authorizeAccountWithCompletion:(void (^)(BTTokenizedCoinbaseAccount __BT_NULLABLE *coinbaseAccount, NSError __BT_NULLABLE *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
