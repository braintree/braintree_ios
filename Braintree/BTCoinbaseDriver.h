#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTAPIClient.h"
#import "BTTokenizedCoinbaseAccount.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTCoinbaseDriver : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

- (void)authorizeAccountWithCompletion:(void (^)(BTTokenizedCoinbaseAccount __BT_NULLABLE *coinbaseAccount, NSError __BT_NULLABLE *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
