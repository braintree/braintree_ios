
#import <Foundation/Foundation.h>

#import <AuthenticationServices/AuthenticationServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTWebAuthenticationSession : NSObject
@property (nonatomic, weak) id<ASWebAuthenticationPresentationContextProviding> presentationContextProvider API_AVAILABLE(ios(13));

- (void)startWithURL:(NSURL*)url callbackURLScheme:(NSString *)callbackURLScheme completionHandler:(void (^)(NSURL * _Nullable callbackURL, NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
