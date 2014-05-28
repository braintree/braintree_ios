#import "BTUIFormField.h"
#import "BTUICardType.h"

@protocol BTUICardNumberFieldDelegate;

@interface BTUICardNumberField : BTUIFormField

@property (nonatomic, weak, readwrite) IBOutlet id<BTUICardNumberFieldDelegate> delegate;

@property (nonatomic, strong, readonly) BTUICardType *cardType;
@property (nonatomic, strong, readonly) NSString *number;

@end

@protocol BTUICardNumberFieldDelegate <NSObject>
- (void)cardNumberFieldDidChange:(BTUICardNumberField *)field;
@end
