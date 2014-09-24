@import Foundation;

#import "BTAPIResource.h"

@interface BTAPIResourceValueTypeError : NSObject <BTAPIResourceValueType>

- (instancetype)initWithErrorCode:(NSInteger)code description:(NSString *)localizedDescription NS_DESIGNATED_INITIALIZER;

+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)format, ...;

@end
