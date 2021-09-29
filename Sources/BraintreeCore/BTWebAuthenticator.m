//
//  BTWebAuthenticator.m
//  BraintreeTestShared
//
//  Created by Shropshire, Steven on 9/29/21.
//

#import "BTWebAuthenticator.h"

typedef void (^AuthenticateWithURLCompletionHandler) (NSURL * _Nullable callbackURL, NSError * _Nullable error);

@interface BTWebAuthenticator ()

@property (nonatomic, strong, nullable) ASWebAuthenticationSession *authenticationSession;

@end

@implementation BTWebAuthenticator

- (void)authenticateWithURL:(NSURL*)url callbackURLScheme:(NSString *)callbackURLScheme completion:(void (^)(NSURL * _Nullable callbackURL, NSError * _Nullable error))completionHandler {
    
    AuthenticateWithURLCompletionHandler internalCompletionHandler =
        ^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
            // Required to avoid memory leak for BTPaymentFlowDriver
            self.authenticationSession = nil;
            completionHandler(callbackURL, error);
        };
    
    _authenticationSession = [[ASWebAuthenticationSession alloc] initWithURL:url callbackURLScheme:callbackURLScheme
      completionHandler:internalCompletionHandler];
    
    if (@available(iOS 13, *)) {
        _authenticationSession.presentationContextProvider = self.presentationContextProvider;
    }
    [_authenticationSession start]; // TODO what if the start fails
}

@end
