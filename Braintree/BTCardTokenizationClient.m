#import "BTCardTokenizationClient_Internal.h"
#import "BTTokenizedCard_Internal.h"
#import "BTHTTP.h"
#import "BTThreeDSecureInfo_Internal.h"
#import "BTJSON.h"
#import "BTClientMetadata.h"
#import "BTConfiguration_Internal.h"
#import "BTCard_Internal.h"

NSString *const BTCardTokenizationClientErrorDomain = @"com.braintreepayments.BTCardTokenizationClientErrorDomain";

@interface BTCardTokenizationClient ()
@property (nonatomic, strong) BTConfiguration *configuration;
@end

@implementation BTCardTokenizationClient

- (nonnull instancetype)initWithConfiguration:(nonnull BTConfiguration *)configuration {
    self = [self init];
    if (self) {
        self.configuration = configuration;
    }

    return self;
}

- (BTHTTP *)clientApiHTTP {
    return self.configuration.clientApiHTTP;
}

- (BTClientMetadata *)clientMetadata {
    BTClientMutableMetadata *clientMetadata = [self.configuration.clientMetadata mutableCopy];
    clientMetadata.integration = BTClientMetadataIntegrationCustom;
    clientMetadata.source = BTClientMetadataSourceUnknown;

    return [clientMetadata copy];
}

- (void)tokenizeCard:(nonnull BTCard *)card completion:(nonnull void (^)(BTTokenizedCard * __nullable, NSError * __nullable))completionBlock {
    [self.clientApiHTTP POST:@"v1/payment_methods/credit_cards"
                  parameters:@{ @"_meta": self.clientMetadata.parameters,
                                @"credit_card": card.parameters }
                  completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
                      if (error != nil) {
                          return completionBlock(nil, error);
                      }

                      if (response.statusCode != 202) {
                          return completionBlock(nil, [NSError errorWithDomain:BTCardTokenizationClientErrorDomain
                                                                          code:BTCardTokenizationClientErrorCodeFatalError
                                                                      userInfo: @{
                                                                                  NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:@"Braintree server returned HTTP status code %ld", (long)response.statusCode] }]);
                      }

                      BTJSON *creditCard = body[@"creditCards"][0];

                      if (!creditCard[@"nonce"].isString || !creditCard[@"description"].isString) {
                          // TODO Handle unhelpful server response
                      }

                      BTThreeDSecureInfo *threeDSecureInfo;
                      if (creditCard[@"threeDSecureInfo"].isObject) {
                          threeDSecureInfo = [BTThreeDSecureInfo infoWithLiabilityShiftPossible:creditCard[@"threeDSecureInfo"][@"liabilityShiftPossible"].isTrue
                                                                               liabilityShifted:creditCard[@"threeDSecureInfo"][@"liabilityShifted"].isTrue];
                      }

                      BTTokenizedCard *tokenizedCard = [[BTTokenizedCard alloc] initWithPaymentMethodNonce:creditCard[@"nonce"].asString
                                                                                               description:creditCard[@"description"].asString
                                                                                               cardNetwork:[creditCard[@"details"][@"cardType"] asEnum:@{
                                                                                                                                                         @"american express": @(BTCardNetworkAMEX),
                                                                                                                                                         @"diners club": @(BTCardNetworkDinersClub),
                                                                                                                                                         @"china unionpay": @(BTCardNetworkUnionPay),
                                                                                                                                                         @"discover": @(BTCardNetworkDiscover),
                                                                                                                                                         @"jcb": @(BTCardNetworkJCB),
                                                                                                                                                         @"maestro": @(BTCardNetworkMaestro),
                                                                                                                                                         @"mastercard": @(BTCardNetworkMasterCard),
                                                                                                                                                         @"solo": @(BTCardNetworkSolo),
                                                                                                                                                         @"switch": @(BTCardNetworkSwitch),
                                                                                                                                                         @"uk maestro": @(BTCardNetworkUKMaestro),
                                                                                                                                                         @"visa": @(BTCardNetworkVisa),}
                                                                                                                                             orDefault:BTCardNetworkUnknown]
                                                                                                   lastTwo:creditCard[@"details"][@"lastTwo"].asString
                                                                                          threeDSecureInfo:threeDSecureInfo];
                      completionBlock(tokenizedCard, nil);
                  }];
}

@end
