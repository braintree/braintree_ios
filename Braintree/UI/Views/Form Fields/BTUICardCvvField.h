#import "BTUIFormField.h"
#import "BTUICardType.h"

@interface BTUICardCvvField : BTUIFormField

@property (nonatomic, strong) BTUICardType *cardType;

@property (nonatomic, strong, readonly) NSString *cvv;

@end
