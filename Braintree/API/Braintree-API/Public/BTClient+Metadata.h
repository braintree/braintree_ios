#import "BTClient.h"
#import "BTClientMetadata.h"

@interface BTClient (Metadata)

@property (nonatomic, copy, readonly) BTClientMetadata *metadata;

///  Copy of the instance, but with different metadata
///
///  Useful for temporary metadata overrides.
///
///  @param clientBlock block to be invoked.
- (instancetype)copyWithMetadata:(void (^)(BTClientMutableMetadata *metadata))metadataBlock;

@end
