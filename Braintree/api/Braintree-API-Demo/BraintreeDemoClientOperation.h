#import <Foundation/Foundation.h>

#import <Braintree/Braintree-API.h>

typedef void (^BraintreeDemoClientOperationDidCompleteBlock)(id, NSError *);

@interface BraintreeDemoClientOperation : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) void (^block)(void (^)(id, NSError *));

- (void)performWithCompletionBlock:(BraintreeDemoClientOperationDidCompleteBlock)operationDidComplete;

@end