#import <Foundation/Foundation.h>
@class BTCard;

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information about a card to tokenize
 */
@interface BTCardRequest : NSObject

/**
 Initialize with an instance of `BTCard`.
 
 @param card The `BTCard` to initialize with.
 */
- (instancetype)initWithCard:(BTCard *)card;

/**
 The `BTCard` associated with this instance.
 */
@property (nonatomic, strong) BTCard *card;

@end

NS_ASSUME_NONNULL_END
