#import "BTCard.h"

@interface BTCard ()

@property (nonatomic, readwrite, assign) BTCardType type;
@property (nonatomic, readwrite, copy) NSString *typeString;
@property (nonatomic, readwrite, copy) NSString *lastTwo;

@end
