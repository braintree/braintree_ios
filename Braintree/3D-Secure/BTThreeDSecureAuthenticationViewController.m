#import "BTThreeDSecureAuthenticationViewController.h"
#import "BTURLUtils.h"
#import "BTClient_Internal.h"
#import "UIColor+BTUI.h"
#import "BTThreeDSecureResponse.h"
#import "BTWebViewController.h"

@interface BTThreeDSecureAuthenticationViewController ()
@property (nonatomic, strong) BTThreeDSecureLookupResult *lookupResult;
@end

@implementation BTThreeDSecureAuthenticationViewController

- (instancetype)initWithLookupResult:(BTThreeDSecureLookupResult *)lookupResult {
    if (!lookupResult.requiresUserAuthentication) {
        return nil;
    }

    self = [super init];
    if (self) {
        self.lookupResult = lookupResult;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(tappedCancel)];

    NSMutableURLRequest *acsRequest = [NSMutableURLRequest requestWithURL:self.lookupResult.acsURL];
    [acsRequest setHTTPMethod:@"POST"];
    NSDictionary *fields = @{ @"PaReq": self.lookupResult.PAReq,
                              @"TermUrl": self.lookupResult.termURL,
                              @"MD": self.lookupResult.MD };
    [acsRequest setHTTPBody:[[BTURLUtils queryStringWithDictionary:fields] dataUsingEncoding:NSUTF8StringEncoding]];
    [acsRequest setAllHTTPHeaderFields:@{ @"Accept": @"text/html", @"Content-Type": @"application/x-www-form-urlencoded"}];
    [self loadRequest:acsRequest];
}

- (void)didCompleteAuthentication:(BTThreeDSecureResponse *)response {
    if (response.success) {
        if ([self.delegate respondsToSelector:@selector(threeDSecureViewController:didAuthenticateCard:completion:)]) {
            [self.delegate threeDSecureViewController:self
                                  didAuthenticateCard:response.paymentMethod
                                           completion:^(__unused BTThreeDSecureViewControllerCompletionStatus status) {
                                               if ([self.delegate respondsToSelector:@selector(threeDSecureViewControllerDidFinish:)]) {
                                                   [self.delegate threeDSecureViewControllerDidFinish:self];
                                               }
                                           }];
        }
    } else {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        if (response.threeDSecureInfo) {
            userInfo[BTThreeDSecureInfoKey] = response.threeDSecureInfo;
        }
        if (response.errorMessage) {
            userInfo[NSLocalizedDescriptionKey] = response.errorMessage;
        }
        NSError *error = [NSError errorWithDomain:BTThreeDSecureErrorDomain
                                             code:BTThreeDSecureFailedAuthenticationErrorCode
                                         userInfo:userInfo];
        if ([self.delegate respondsToSelector:@selector(threeDSecureViewController:didFailWithError:)]) {
            [self.delegate threeDSecureViewController:self didFailWithError:error];
        }
        if ([self.delegate respondsToSelector:@selector(threeDSecureViewControllerDidFinish:)]) {
            [self.delegate threeDSecureViewControllerDidFinish:self];
        }
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeFormSubmitted && [request.URL.path rangeOfString:@"authentication_complete_frame"].location != NSNotFound) {
        NSString *rawAuthResponse = [BTURLUtils dictionaryForQueryString:request.URL.query][@"auth_response"];
        NSDictionary *authResponseDictionary = [NSJSONSerialization JSONObjectWithData:[rawAuthResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                               options:0
                                                                                 error:NULL];
        
        BTThreeDSecureResponse *authResponse = [[BTThreeDSecureResponse alloc] init];
        authResponse.success = [authResponseDictionary[@"success"] boolValue];
        authResponse.threeDSecureInfo = authResponseDictionary[@"threeDSecureInfo"];
        
        NSDictionary *paymentMethodDictionary = authResponseDictionary[@"paymentMethod"];
        if ([paymentMethodDictionary isKindOfClass:[NSDictionary class]]) {
            authResponse.paymentMethod = [BTClient cardFromAPIResponseDictionary:paymentMethodDictionary];
        }
        authResponse.errorMessage = authResponseDictionary[@"error"][@"message"];

        [self didCompleteAuthentication:authResponse];

        return NO;
    } else {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
}

#pragma mark User Interaction

- (void)tappedCancel {
    if ([self.delegate respondsToSelector:@selector(threeDSecureViewControllerDidFinish:)]) {
        [self.delegate threeDSecureViewControllerDidFinish:self];
    }
}

@end
