#import "BraintreeDemoClientOperation.h"

@implementation BraintreeDemoClientOperation

- (void)performWithCompletionBlock:(BraintreeDemoClientOperationDidCompleteBlock)operationDidComplete {
    if (self.block) {
        self.block(^(id result, NSError *error){
            if (operationDidComplete) {
                operationDidComplete(result, error);
            }
        });
    }
}

@end
