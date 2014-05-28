#import "BTUIFormField.h"
#import "BTUICardType.h"

@protocol BTUICardCvvFieldDelegate;

@interface BTUICardCvvField : BTUIFormField

@property (nonatomic, strong) BTUICardType *cardType;

@property (nonatomic, weak, readwrite) id<BTUICardCvvFieldDelegate> delegate;
@property (nonatomic, strong, readonly) NSString *cvv;

@end

@protocol BTUICardCvvFieldDelegate <NSObject>
- (void)cardCvvDidChange:(BTUICardCvvField *)field;
@end
