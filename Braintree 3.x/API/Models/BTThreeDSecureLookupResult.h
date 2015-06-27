#import <Foundation/Foundation.h>

#import "BTCardPaymentMethod.h"

@interface BTThreeDSecureLookupResult : NSObject

@property (nonatomic, copy) NSString *PAReq;
@property (nonatomic, copy) NSString *MD;
@property (nonatomic, copy) NSURL *acsURL;
@property (nonatomic, copy) NSURL *termURL;

@property (nonatomic, strong) BTCardPaymentMethod *card;

- (BOOL)requiresUserAuthentication;

@end
