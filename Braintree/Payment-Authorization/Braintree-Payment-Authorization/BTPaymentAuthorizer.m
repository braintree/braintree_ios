#import "BTPaymentAuthorizer.h"
#import "BTClient.h"
#import "BTPaymentAuthorizer_Protected.h"
#import "BTPaymentAuthorizerPayPal.h"
#import "BTPaymentAuthorizerVenmo.h"

@implementation BTPaymentAuthorizer

- (instancetype)initWithType:(BTPaymentAuthorizationType)type
                      client:(BTClient *)client {
    switch (type) {
        case BTPaymentAuthorizationTypePayPal:
            self = [[BTPaymentAuthorizerPayPal alloc] init];
            break;
        case BTPaymentAuthorizationTypeVenmo:
            self = [[BTPaymentAuthorizerVenmo alloc] init];
            break;
        default:
            break;
    }
    self.client = client;
    return self;
}

- (void)authorize {
    [NSException raise:@"Unimplemented abstract authorization" format:nil];
}

- (void)informDelegate:(SEL)selector {
    [self informDelegate:selector args:@[]];
}

- (void)informDelegate:(SEL)selector args:(NSArray *)args {
    if ([self.delegate respondsToSelector:selector]) {
        NSMethodSignature *signature = [NSMutableArray instanceMethodSignatureForSelector:@selector(addObject:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self.delegate];
        [invocation setSelector:selector];
        id arg = self;
        [invocation setArgument:&arg atIndex:0];
        for (NSUInteger i = 0; i < args.count; i++) {
            arg = args[i];
            [invocation setArgument:&arg atIndex:i + 1];
        }
        [invocation invoke];
    }
}

@end
