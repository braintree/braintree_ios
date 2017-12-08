#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#if __has_include("BraintreeCard.h")
#import "BTCardNonce.h"
#else
#import <BraintreeCard/BTCardNonce.h>
#endif
#import "BTPaymentFlowResult.h"
#import "BTThreeDSecureResult.h"

@interface BTThreeDSecureLookup : BTPaymentFlowResult

@property (nonatomic, copy) NSString *PAReq;
@property (nonatomic, copy) NSString *MD;
@property (nonatomic, copy) NSURL *acsURL;
@property (nonatomic, copy) NSURL *termURL;
@property (nonatomic, strong) BTThreeDSecureResult *threeDSecureResult;

- (BOOL)requiresUserAuthentication;

@end
