#import "BTThreeDSecureDriver.h"


@interface BTThreeDSecureDriver ()

@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, strong) BTThreeDSecureTokenizedCard *upgradedTokenizedCard;
@property (nonatomic, copy) void (^completionBlockAfterAuthenticating)(BTThreeDSecureTokenizedCard *, NSError *);

@end

