#import "BTThreeDSecureAuthenticationViewController.h"
#import "BTURLUtils.h"
#import "BTClient_Internal.h"
#import "UIColor+BTUI.h"
#import "BTThreeDSecureResponse.h"
#import "BTWebViewController.h"
#import "BTAPIResponseParser.h"
#import "BTClientTokenBooleanValueTransformer.h"
#import "BTClientPaymentMethodValueTransformer.h"

@interface BTThreeDSecureAuthenticationViewController ()
@end

@implementation BTThreeDSecureAuthenticationViewController

- (instancetype)initWithLookupResult:(BTThreeDSecureLookupResult *)lookupResult {
    if (!lookupResult.requiresUserAuthentication) {
        return nil;
    }

    NSURLRequest *acsRequest = [self acsRequestForLookupResult:lookupResult];
    return [super initWithRequest:acsRequest];
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
    return [self initWithRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(tappedCancel)];
}

- (NSURLRequest *)acsRequestForLookupResult:(BTThreeDSecureLookupResult *)lookupResult {
    NSMutableURLRequest *acsRequest = [NSMutableURLRequest requestWithURL:lookupResult.acsURL];
    [acsRequest setHTTPMethod:@"POST"];
    NSDictionary *fields = @{ @"PaReq": lookupResult.PAReq,
                              @"TermUrl": lookupResult.termURL,
                              @"MD": lookupResult.MD };
    [acsRequest setHTTPBody:[[BTURLUtils queryStringWithDictionary:fields] dataUsingEncoding:NSUTF8StringEncoding]];
    [acsRequest setAllHTTPHeaderFields:@{ @"Accept": @"text/html", @"Content-Type": @"application/x-www-form-urlencoded"}];
    return acsRequest;
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
        BTAPIResponseParser *authResponseParser = ({
            NSDictionary *authResponseDictionary = [NSJSONSerialization JSONObjectWithData:[rawAuthResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                                   options:0
                                                                                     error:NULL];
            [BTAPIResponseParser parserWithDictionary:authResponseDictionary];
        });

        BTThreeDSecureResponse *authResponse = [[BTThreeDSecureResponse alloc] init];
        authResponse.success = [authResponseParser boolForKey:@"success"
                                         withValueTransformer:[BTClientTokenBooleanValueTransformer sharedInstance]];
        authResponse.threeDSecureInfo = [authResponseParser dictionaryForKey:@"threeDSecureInfo"];

        authResponse.paymentMethod = [authResponseParser objectForKey:@"paymentMethod"
                                                 withValueTransformer:[BTClientPaymentMethodValueTransformer sharedInstance]];
        authResponse.errorMessage = [[authResponseParser responseParserForKey:@"error"] stringForKey:@"message"];
        [self didCompleteAuthentication:authResponse];

        return NO;
    } else {
        return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102) {
        // Not a real error; occurs when we return NO from webView:shouldStartLoadWithRequest:navigationType:
        return;
    } else if ([error.domain isEqualToString:BTThreeDSecureErrorDomain]) {
        // Allow delegate to handle 3D Secure authentication errors
        [self.delegate threeDSecureViewController:self didFailWithError:error];
    } else {
        // Otherwise, allow the WebViewController to display the error to the user
        if ([self.delegate respondsToSelector:@selector(threeDSecureViewController:didPresentErrorToUserForURLRequest:)]) {
            [self.delegate threeDSecureViewController:self didPresentErrorToUserForURLRequest:webView.request];
        }
        [super webView:webView didFailLoadWithError:error];
    }
}

#pragma mark User Interaction

- (void)tappedCancel {
    if ([self.delegate respondsToSelector:@selector(threeDSecureViewControllerDidFinish:)]) {
        [self.delegate threeDSecureViewControllerDidFinish:self];
    }
}

@end
