#import "BraintreeAppSwitchAuthResponse.h"
#import <NSURL+QueryDictionary.h>

@interface BraintreeAppSwitchAuthResponse ()

@property (nonatomic, copy) NSString *sourceApplication;
@property (nonatomic, copy) NSString *authCode;
@property (nonatomic, copy) NSString *path;
@end

@implementation BraintreeAppSwitchAuthResponse


+ (BraintreeAppSwitchAuthResponse *)authResponseWithURL:(NSURL *)url sourceApplication:(NSString *)sourceApp{
    return  [[BraintreeAppSwitchAuthResponse alloc] initWithURL:url sourceApplication:sourceApp];
}

- (instancetype)initWithURL:(NSURL *) url sourceApplication:(NSString *)sourceApp{
    self = [super init];
    if (self){
        //com.braintreepayments.demo-app.v1://x-callback-url/wlt-auth-return/success?auth_code=success-1234
        self.sourceApplication = sourceApp;
        self.authCode = [url uq_queryDictionary][@"auth_code"];
        self.path = url.path;
    }
    return self;
}

- (BraintreeAppSwitchAuthResponseStatus)status{

    NSArray *pathComponents = [self.path componentsSeparatedByString:@"/"];
    BraintreeAppSwitchAuthResponseStatus returnStatus = BraintreeAppSwitchAuthResponseUnknown;
    
    if (pathComponents.count > 0){
        NSString *statusComponent = [pathComponents lastObject];

        if ([statusComponent isEqualToString:@"success"]){
            returnStatus = BraintreeAppSwitchAuthResponseSuccess;
        } else if ([statusComponent isEqualToString:@"error"]){
            returnStatus = BraintreeAppSwitchAuthResponseError;
        } else if ([statusComponent isEqualToString:@"cancel"]){
           returnStatus = BraintreeAppSwitchAuthResponseCancel;
        }
    }
    return returnStatus;
}

@end
