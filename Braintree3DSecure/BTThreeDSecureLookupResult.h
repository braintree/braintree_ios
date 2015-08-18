#import <Foundation/Foundation.h>

#import "BTThreeDSecureTokenizedCard.h"

@interface BTThreeDSecureLookupResult : NSObject

@property (nonatomic, copy) NSString *PAReq;
@property (nonatomic, copy) NSString *MD;
@property (nonatomic, copy) NSURL *acsURL;
@property (nonatomic, copy) NSURL *termURL;

@property (nonatomic, strong) BTThreeDSecureTokenizedCard *tokenizedCard;

- (BOOL)requiresUserAuthentication;

@end
