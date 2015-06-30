#import "BTCardTokenizationClient.h"
#import "BTTokenizedCard_Internal.h"
#import "BTAPIClient.h"
#import "BTThreeDSecureInfo_Internal.h"
#import "BTJSON.h"

@interface BTCardTokenizationClient ()
@property (nonatomic, strong) BTAPIClient *client;
@end

@implementation BTCardTokenizationClient

- (nonnull instancetype)initWithConfiguration:(nonnull BTConfiguration *)configuration {
    self = [self init];
    if (self) {
        // TODO Set Base URL
        _client = [[BTAPIClient alloc] initWithBaseURL:[NSURL URLWithString:@""] authorizationFingerprint:configuration.key];
    }

    return self;
}

- (nonnull instancetype)initWithConfiguration:(nonnull BTConfiguration *)configuration apiClient:(nonnull BTAPIClient *)client {
    self = [self init];
    if (self) {
        _client = client;
    }
    return self;
}

- (void)tokenizeCard:(nonnull BTCard *)card completion:(nonnull void (^)(BTTokenizedCard * __nullable, NSError * __nullable))completionBlock {

    BTJSON *parameters = [[BTJSON alloc] init];
    //    parameters[@"credit_card"] = card.parameters;

    // TODO populate metaPostParameters correctly
    //    parameters[@"_meta"][@"source"] = @"unknown";
    //    parameters[@"_meta"][@"integration"] = @"unknown";

    [self.client POST:@"v1/payment_methods/credit_cards"
           parameters:parameters
           completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {
               if (error != nil) {
                   return completionBlock(nil, error);
               }

               // TODO return a better error message when tokenization fails
               if (response.statusCode >= 300) {
                   return completionBlock(nil, [NSError errorWithDomain:@"Braintree" code:0 userInfo:nil]);
               }

               BTJSON *creditCard = body[@"creditCards"][0];

               if (!creditCard[@"nonce"].isString || !creditCard[@"description"].isString) {
                   // TODO Handle unhelpful server response
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
                                                                                   threeDSecureInfo:[BTThreeDSecureInfo infoWithLiabilityShiftPossible:creditCard[@"threeDSecureInfo"][@"liabilityShiftPossible"].isTrue
                                                                                                                                      liabilityShifted:creditCard[@"threeDSecureInfo"][@"liabilityShifted"].isTrue]];
               completionBlock(tokenizedCard, nil);
           }];
}

@end
