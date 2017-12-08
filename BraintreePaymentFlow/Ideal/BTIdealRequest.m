#import "BTIdealRequest.h"
#import "BTConfiguration+Ideal.h"
#if __has_include("BTLogger_Internal.h")
#import "BTLogger_Internal.h"
#else
#import <BraintreeCore/BTLogger_Internal.h>
#endif
#if __has_include("BTAPIClient_Internal.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif
#import "BTPaymentFlowDriver_Internal.h"
#import "BTIdealRequest.h"
#import "Braintree-Version.h"
#import <SafariServices/SafariServices.h>
#import "BTIdealResult.h"
#import "BTPaymentFlowDriver+Ideal_Internal.h"

@interface BTIdealRequest ()

@property (nonatomic, copy, nullable) NSString *idealId;
@property (nonatomic, weak) id<BTPaymentFlowDriverDelegate> paymentFlowDriverDelegate;

@end

@implementation BTIdealRequest

- (void)handleRequest:(BTPaymentFlowRequest *)request client:(BTAPIClient *)apiClient paymentDriverDelegate:(id<BTPaymentFlowDriverDelegate>)delegate {
    self.paymentFlowDriverDelegate = delegate;
    BTIdealRequest *idealRequest = (BTIdealRequest *)request;
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *configurationError) {
        if (configurationError) {
            [delegate onPaymentComplete:nil error:configurationError];
            return;
        }
        
        if (!configuration.isIdealEnabled) {
            NSError *error = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain code:BTPaymentFlowDriverErrorTypeDisabled userInfo:@{NSLocalizedDescriptionKey: @"iDEAL is not enabled for this merchant"}];
            [delegate onPaymentComplete:nil error:error];
            return;
        } else if ([self.paymentFlowDriverDelegate returnURLScheme] == nil || [[self.paymentFlowDriverDelegate returnURLScheme] isEqualToString:@""]) {
            [[BTLogger sharedLogger] critical:@"iDEAL requires a return URL scheme to be configured via [BTAppSwitch setReturnURLScheme:]"];
            NSError *error = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                                 code:BTPaymentFlowDriverErrorTypeInvalidReturnURL
                                             userInfo:@{NSLocalizedDescriptionKey: @"UIApplication failed to perform app or browser switch."}];
            [delegate onPaymentComplete:nil error:error];
            return;
        } else if (idealRequest.orderId == nil || idealRequest.issuer == nil || idealRequest.amount == nil || idealRequest.currency == nil) {
            [[BTLogger sharedLogger] critical:@"BTIdealRequest amount, currency, issuer and orderId can not be nil."];
            NSError *error = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                                 code:BTPaymentFlowDriverErrorTypeIntegration
                                             userInfo:@{NSLocalizedDescriptionKey: @"Failed to begin iDEAL payment flow: BTIdealRequest amount, currency, issuer and orderId can not be nil."}];
            [delegate onPaymentComplete:nil error:error];
            return;
        }
        
        NSString *redirectUrl = [NSString stringWithFormat: @"%@/mobile/ideal-redirect/0.0.0/index.html?redirect_url=%@://x-callback-url/braintree/ideal/",
                                 configuration.idealAssetsUrl,
                                 [delegate returnURLScheme]
                                 ];
        
        NSDictionary *params = @{
                                 @"route_id": configuration.routeId,
                                 @"order_id": idealRequest.orderId,
                                 @"issuer": idealRequest.issuer,
                                 @"amount": idealRequest.amount,
                                 @"currency": idealRequest.currency,
                                 @"redirect_url": redirectUrl,
                                 };
        
        [apiClient POST:@"ideal-payments"
                  parameters:params
                  httpType: BTAPIClientHTTPTypeBraintreeAPI
                  completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error)
         {
             if (!error) {
                 BTIdealResult *idealResult = [[BTIdealResult alloc] init];
                 idealResult.idealId = [body[@"data"][@"id"] asString];
                 idealResult.shortIdealId = [body[@"data"][@"short_id"] asString];
                 idealResult.status = [body[@"data"][@"status"] asString];
                 self.idealId = idealResult.idealId;
                 NSString *approvalUrl = [body[@"data"][@"approval_url"] asString];
                 NSURL *url = [NSURL URLWithString:approvalUrl];
                 if (self.idealPaymentFlowDelegate) {
                     [self.idealPaymentFlowDelegate idealPaymentStarted:idealResult];
                 }
                 [delegate onPaymentWithURL:url error:error];
             } else {
                 [delegate onPaymentWithURL:nil error:error];
             }
         }];
    }];
}

- (void)handleOpenURL:(__unused NSURL *)url {
    BTPaymentFlowDriver *paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:[self.paymentFlowDriverDelegate apiClient]];
    [paymentFlowDriver checkStatus:self.idealId completion:^(BTPaymentFlowResult * _Nonnull result, NSError * _Nonnull error) {
        [self.paymentFlowDriverDelegate onPaymentComplete:result error:error];
    }];
}

- (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(__unused NSString *)sourceApplication {
    return [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/braintree/ideal"];
}

- (NSString *)paymentFlowName {
    return @"ideal";
}

@end
