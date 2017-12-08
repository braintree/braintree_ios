#import "BTPaymentFlowDriver+Ideal.h"
#import "BTConfiguration+Ideal.h"
#import "BTAPIClient_Internal.h"
#import "BTPaymentFlowDriver_Internal.h"
#import "BTIdealResult.h"

@implementation BTPaymentFlowDriver (Ideal)

#pragma mark - Fetch Banks

- (void)fetchIssuingBanks:(void (^)(NSArray<BTIdealBank *> * _Nullable, NSError * _Nullable))completionBlock {
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        if (!configuration.isIdealEnabled) {
            NSError *error = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain code:BTPaymentFlowDriverErrorTypeDisabled userInfo:@{NSLocalizedDescriptionKey: @"iDEAL is not enabled for this merchant"}];
            completionBlock(nil, error);
            return;
        }
        
        [self.apiClient GET:@"issuers/ideal"
                 parameters:@{}
                 httpType: BTAPIClientHTTPTypeBraintreeAPI
                 completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error)
         {
             if (error) {
                 [self.apiClient sendAnalyticsEvent:@"ios.ideal.load.failed"];
                 completionBlock(nil, error);
             } else {
                 [self.apiClient sendAnalyticsEvent:@"ios.ideal.load.succeeded"];
                 NSMutableArray *banks = [NSMutableArray array];
                 for (BTJSON *data in [body[@"data"] asArray]) {
                     NSString *countryCode = data[@"country_code"];
                     for (BTJSON *issuerJson in data[@"issuers"]) {
                         NSString *issuerId = issuerJson[@"id"];
                         NSString *imageFileName = issuerJson[@"image_file_name"];
                         NSString *assetUrl = [configuration.json[@"assetsUrl"] asString];
                         NSString *imagePath = [NSString stringWithFormat:@"%@/web/static/images/ideal_issuer-logo_%@", assetUrl, imageFileName];
                         NSString *name = issuerJson[@"name"];
                         BTIdealBank *bank = [[BTIdealBank alloc] initWithCountryCode:countryCode issuerId:issuerId name:name imageUrl:imagePath];
                         [banks addObject:bank];
                     }
                 }
                 completionBlock(banks, nil);
             }
         }];
    }];
}

- (void)pollForCompletionWithId:(NSString *)idealId retries:(int)retries delay:(int)delay completion:(void (^)(BTPaymentFlowResult * _Nullable result, NSError * _Nullable error))completionBlock {
    if (retries < 0 || retries > 10 || delay < 1000 || delay > 10000) {
        NSError *error = [NSError errorWithDomain:BTPaymentFlowDriverErrorDomain
                                             code:BTPaymentFlowDriverErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to begin polling: retries must be between 0 and 10, delay must be between 1000 and 10000."}];
        completionBlock(nil, error);
        return;
    }

    [self pollForCompletionWithId:idealId retries:retries delay:delay retryCount:0 completion:completionBlock];
}

- (void)pollForCompletionWithId:(NSString *)idealId retries:(int)retries delay:(int)delay retryCount:(int)retryCount completion:(void (^)(BTPaymentFlowResult * _Nullable result, NSError * _Nullable error))completionBlock {
    [self.apiClient sendAnalyticsEvent:@"ios.ideal.polling.started"];
    [self checkStatus:idealId completion:^(BTPaymentFlowResult *result, NSError *error) {
        if (error) {
            completionBlock(nil, error);
        } else {
            BTIdealResult *idealResult = (BTIdealResult *)result;
            if ([idealResult.status isEqualToString:@"PENDING"] && retryCount < retries) {
                double seconds = ((double)delay)/1000.0;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self pollForCompletionWithId:idealId retries:retries delay:delay retryCount:retryCount+1 completion:completionBlock];
                });
            } else {
                completionBlock(idealResult, nil);
            }
        }
    }];
}

- (void)checkStatus:(NSString *)idealId completion:(void (^)(BTPaymentFlowResult *idealResult, NSError *error))completionBlock {
    NSString *path = [NSString stringWithFormat:@"/ideal-payments/%@/status", idealId];
    [self.apiClient GET:path
             parameters:@{}
               httpType: BTAPIClientHTTPTypeBraintreeAPI
             completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error)
     {
         if (error) {
             completionBlock(nil, error);
         } else {
             BTIdealResult *idealResult = [[BTIdealResult alloc] init];
             idealResult.idealId = [body[@"data"][@"id"] asString];
             idealResult.shortIdealId = [body[@"data"][@"short_id"] asString];
             idealResult.status = [body[@"data"][@"status"] asString];
             completionBlock(idealResult, nil);
         }
     }];
}

@end
