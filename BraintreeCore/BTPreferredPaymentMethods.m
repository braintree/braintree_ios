#import "BTPreferredPaymentMethods_Internal.h"
#import "BTAPIClient_Internal.h"
#import "BTPreferredPaymentMethodsResult_Internal.h"
#import "BTConfiguration+GraphQL.h"

@interface BTPreferredPaymentMethods()

@property (nonatomic, strong) BTAPIClient *apiClient;

@end

@implementation BTPreferredPaymentMethods

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
        _application = UIApplication.sharedApplication;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (void)fetchPreferredPaymentMethods:(void (^)(BTPreferredPaymentMethodsResult * _Nonnull result))completion {
    if ([self.application canOpenURL:[NSURL URLWithString:@"paypal://"]]) {
        BTPreferredPaymentMethodsResult *result = [BTPreferredPaymentMethodsResult new];
        result.isPayPalPreferred = YES;
        [self.apiClient sendAnalyticsEvent:@"ios.preferred-payment-methods.paypal.app-installed.true"];
        completion(result);
        return;
    }
    
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *configError) {
        
        if (!configError && configuration.isGraphQLEnabled) {
            NSDictionary *parameters = @{ @"query": @"query ClientConfiguration { clientConfiguration { paypal { preferredPaymentMethod } } }" };
            
            [self.apiClient POST:@"" parameters:parameters httpType:BTAPIClientHTTPTypeGraphQLAPI completion:^(BTJSON *body,
                                                                                                               __unused NSHTTPURLResponse *response,
                                                                                                               NSError *preferredPaymentMethodsError) {
                BTPreferredPaymentMethodsResult *result = [[BTPreferredPaymentMethodsResult alloc] initWithJSON:body];
                
                if (preferredPaymentMethodsError || !body) {
                    [self.apiClient sendAnalyticsEvent:@"ios.preferred-payment-methods.api-error"];
                } else {
                    [self.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.preferred-payment-methods.paypal.api-detected.%@", result.isPayPalPreferred ? @"true" : @"false"]];
                }
                completion(result);
            }];
        } else {
            BTPreferredPaymentMethodsResult *result = [BTPreferredPaymentMethodsResult new];
            result.isPayPalPreferred = NO;
            
            if (configError) {
                [self.apiClient sendAnalyticsEvent:@"ios.preferred-payment-methods.api-error"];
            } else {
                [self.apiClient sendAnalyticsEvent:@"ios.preferred-payment-methods.api-disabled"];
            }
            completion(result);
        }
    }];
}

@end
