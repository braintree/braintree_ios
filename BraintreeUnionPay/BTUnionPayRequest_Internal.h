#import "BTUnionPayRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTUnionPayRequest()

/// The unique identifier that is returned when a Union Pay card is successfully enrolled.
/// This is exposed internally so that BTCardClient can read/write this value on instances
/// of `BTUnionPayRequest`.
@property (nonatomic, copy) NSString *enrollmentID;

@end

NS_ASSUME_NONNULL_END
