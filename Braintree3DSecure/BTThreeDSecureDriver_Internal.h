#import "BTThreeDSecureDriver.h"


@interface BTThreeDSecureDriver ()

@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, strong) BTThreeDSecureCardNonce *upgradedTokenizedCard;
@property (nonatomic, copy) void (^completionBlockAfterAuthenticating)(BTThreeDSecureCardNonce *, NSError *);

@end

