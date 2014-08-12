#import <Foundation/Foundation.h>

@interface BraintreeAppSwitchAuthResponse : NSObject

typedef NS_ENUM(NSInteger, BraintreeAppSwitchAuthResponseStatus){
    BraintreeAppSwitchAuthResponseSuccess = 1,
    BraintreeAppSwitchAuthResponseError = 2,
    BraintreeAppSwitchAuthResponseCancel = 3,
    BraintreeAppSwitchAuthResponseUnknown = 4,
};

@property (nonatomic, copy, readonly) NSString *sourceApplication;

//Too specific to PP?
@property (nonatomic, copy, readonly) NSString *authCode;

@property (nonatomic, assign, readonly) BraintreeAppSwitchAuthResponseStatus status;


+ (BraintreeAppSwitchAuthResponse *)authResponseWithURL:(NSURL *)url sourceApplication:(NSString *)sourceApp;



@end
