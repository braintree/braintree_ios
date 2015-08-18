#import <Foundation/Foundation.h>
#import "BTThreeDSecureTokenizedCard.h"

@interface BTThreeDSecureResponse : NSObject

@property (nonatomic, assign) BOOL success;
@property (nonatomic, strong) NSDictionary *threeDSecureInfo;
@property (nonatomic, strong) BTThreeDSecureTokenizedCard *tokenizedCard;
@property (nonatomic, copy) NSString *errorMessage;

@end
