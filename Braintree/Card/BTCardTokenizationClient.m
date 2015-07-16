#import "BTCardTokenizationClient.h"
#import "BTTokenizedCard_Internal.h"
#import "BTHTTP.h"
#import "BTJSON.h"
#import "BTClientMetadata.h"
#import "BTAPIClient_Internal.h"
#import "BTCardTokenizationRequest_Internal.h"

NSString *const BTCardTokenizationClientErrorDomain = @"com.braintreepayments.BTCardTokenizationClientErrorDomain";

@interface BTCardTokenizationClient ()
@property (nonatomic, strong) BTAPIClient *apiClient;
@end

@implementation BTCardTokenizationClient

- (nonnull instancetype)initWithAPIClient:(nonnull BTAPIClient *)apiClient {
    self = [self init];
    if (self) {
        self.apiClient = apiClient;
    }

    return self;
}

- (BTHTTP *)clientApiHTTP {
    return self.apiClient.http;
}

- (void)tokenizeCard:(BTCardTokenizationRequest *)card
          completion:(void (^)(BTTokenizedCard *, NSError *))completionBlock {

    [self.apiClient POST:@"v1/payment_methods/credit_cards"
              parameters:@{ @"_meta": self.apiClient.metadata.parameters,
                            @"credit_card": card.parameters }
              completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                  if (error != nil) {
                      completionBlock(nil, error);
                      return;
                  }

                  // TODO: handle 422 error codes, provide better context for validation errors

                  BTJSON *creditCard = body[@"creditCards"][0];

                  // TODO: figure out where invalid JSON server repsonses should generate NSErrors. Here? BTTokenizedCard?
                  if (creditCard.isError) {
                      completionBlock(nil, creditCard.asError);
                  } else {
                      completionBlock([BTTokenizedCard cardWithJSON:creditCard], nil);
                  }
              }];
}

@end
