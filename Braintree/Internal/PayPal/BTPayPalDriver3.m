#import "BTPayPalDriver3.h"

#import "PayPalOneTouchRequest.h"
#import "PayPalOneTouchCore.h"

#import "BTTokenizedPayPalAccount_Internal.h"
#import "BTLogger_Internal.h"
#import "BTConfiguration_Internal.h"
#import "BTPostalAddress_Internal.h"
#import "BTClientMetadata.h"


#import "BTAppSwitch.h"


NSString *const BTPayPalDriver3ErrorDomain = @"com.braintreepayments.BTPayPalDriver3ErrorDomain";

@interface BTPayPalDriver3 ()
@property (nonatomic, strong) BTConfiguration *configuration;
@property (nonatomic, strong) BTAPIClient *client;
@property (nonatomic, copy) NSString *returnURLScheme;
@end

@implementation BTPayPalDriver3

- (instancetype)initWithConfiguration:(BTConfiguration * __nonnull)configuration {
    NSError *initializationError;
    if (![BTPayPalDriver3 verifyAppSwitchConfiguration:configuration
                                       returnURLScheme:configuration.returnURLScheme
                                                 error:&initializationError]) {
        [[BTLogger sharedLogger] log:@"Failed to initialize BTPayPalDriver3: %@", initializationError];
        return nil;
    }

    self = [super init];
    if (self) {
        self.configuration = configuration;
        self.client = [[BTAPIClient alloc] initWithBaseURL:configuration.baseURL authorizationFingerprint:configuration.clientKey];
        self.returnURLScheme = configuration.returnURLScheme;
    }
    return self;
}

#pragma mark - PayPal Lifecycle

- (void)startCheckout:(__unused BTPayPalCheckout *)checkout completion:(__unused void (^)(BTPayPalPaymentMethod *paymentMethod, NSError *error))completionBlock {
    NSError *error;
    BTClient *client = [self copyClientForPayPal:self.client error:&error];
    
    if (error) {
        if (completionBlock) {
            completionBlock(nil, error);
        }
        return;
    }
    
    if (checkout == nil) {
        [[BTLogger sharedLogger] log:@"BTPayPalDriver3 failed to start checkout - checkout must not be nil."];
        return;
    }
    
    NSString *redirectUri;
    NSString *cancelUri;
    [PayPalOneTouchCore redirectURLsForCallbackURLScheme:self.returnURLScheme
                                           withReturnURL:&redirectUri
                                           withCancelURL:&cancelUri];
    
    [client createPayPalPaymentResourceWithAmount:checkout.amount
                                     currencyCode:checkout.currencyCode ?: client.configuration.payPalCurrencyCode
                                      redirectUri:redirectUri
                                        cancelUri:cancelUri
                                 clientMetadataID:[PayPalOneTouchCore clientMetadataID]
                                          success:^(BTClientPayPalPaymentResource *paymentResource) {                                              
                                              BTPayPalHandleURLContinuation = ^(NSURL *url){
                                                  [self informDelegateWillProcessAppSwitchResult];
                                                  
                                                  [PayPalOneTouchCore parseResponseURL:url
                                                                       completionBlock:^(PayPalOneTouchCoreResult *result) {
                                                                           BTClient *client = [self clientWithMetadataForResult:result];
                                                                           
                                                                           [self postAnalyticsEventWithClientForSinglePayment:client forHandlingOneTouchResult:result];
                                                                           
                                                                           switch (result.type) {
                                                                               case PayPalOneTouchResultTypeError:
                                                                                   if (completionBlock) {
                                                                                       completionBlock(nil, result.error);
                                                                                   }
                                                                                   break;
                                                                               case PayPalOneTouchResultTypeCancel:
                                                                                   if (result.error) {
                                                                                       [[BTLogger sharedLogger] error:@"PayPal error: %@", result.error];
                                                                                       return;
                                                                                   }
                                                                                   if (completionBlock) {
                                                                                       completionBlock(nil, nil);
                                                                                   }
                                                                                   break;
                                                                               case PayPalOneTouchResultTypeSuccess: {
                                                                                   [client savePaypalAccount:result.response
                                                                                            clientMetadataID:[PayPalOneTouchCore clientMetadataID]
                                                                                                     success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                                                         [self postAnalyticsEventForTokenizationSuccessWithClientForSinglePayment:client];
                                                                                                         
                                                                                                         if (completionBlock) {
                                                                                                             completionBlock(paypalPaymentMethod, nil);
                                                                                                         }
                                                                                                     } failure:^(NSError *error) {
                                                                                                         [self postAnalyticsEventForTokenizationFailureWithClientForSinglePayment:client];
                                                                                                         if (completionBlock) {
                                                                                                             completionBlock(nil, error);
                                                                                                         }
                                                                                                     }];
                                                                                   
                                                                               }
                                                                                   break;
                                                                           }
                                                                           BTPayPalHandleURLContinuation = nil;
                                                                       }];
                                              };
                                              
                                              NSString *payPalClientId = client.configuration.payPalClientId;
                                              if (!payPalClientId && [self payPalEnvironmentForClient:client] == PayPalEnvironmentMock) {
                                                  payPalClientId = @"FAKE-PAYPAL-CLIENT-ID";
                                              }
                                              
                                              PayPalOneTouchCheckoutRequest *request = [PayPalOneTouchCheckoutRequest requestWithApprovalURL:paymentResource.redirectURL
                                                                                                                                    clientID:payPalClientId
                                                                                                                                 environment:[self payPalEnvironmentForClient:client]
                                                                                                                           callbackURLScheme:self.returnURLScheme];
                                              [self informDelegateWillPerformAppSwitch];
                                              [request performWithCompletionBlock:^(BOOL success, PayPalOneTouchRequestTarget target, NSError *error) {
                                                  [self postAnalyticsEventWithClientForSinglePayment:client forInitiatingOneTouchWithSuccess:success target:target];
                                                  if (success) {
                                                      [self informDelegateDidPerformAppSwitchToTarget:target];
                                                  } else {
                                                      if (completionBlock) {
                                                          completionBlock(nil, error);
                                                      }
                                                  }
                                              }];
                                          }
                                          failure:^(NSError *error) {
                                              completionBlock(nil, error);
                                          }];
}



#pragma mark -



@end
