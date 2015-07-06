#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BTNullability.h"
#import "BTAPIClient.h"
#import "BTTokenizedCard.h"
#import "BTThreeDSecureVerification.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureDriver : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

- (void)performVerification:(BTThreeDSecureVerification *)verification
              authorization:(void (^)(UIViewController *authorizationViewController))authorizationBlock
                 completion:(void (^)(BTTokenizedCard __BT_NULLABLE *card, NSError __BT_NULLABLE *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
