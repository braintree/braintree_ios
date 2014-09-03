#import "BTPaymentAuthorizer.h"

@interface BTPaymentAuthorizer () {
@protected
    BTClient *_client;
}

@property (nonatomic, assign) BTPaymentAuthorizationType type;
@property (nonatomic, strong) BTClient *client;

- (void)informDelegate:(SEL)selector;
- (void)informDelegate:(SEL)selector args:(NSArray *)args;

@end

