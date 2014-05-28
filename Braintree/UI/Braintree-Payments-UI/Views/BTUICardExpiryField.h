#import "BTUIFormField.h"

@protocol BTUICardExpiryFieldDelegate;

@interface BTUICardExpiryField : BTUIFormField

@property (nonatomic, weak, readwrite) id<BTUICardExpiryFieldDelegate> delegate;
@property (nonatomic, strong, readonly) NSString *expirationMonth;
@property (nonatomic, strong, readonly) NSString *expirationYear;

@end

@protocol BTUICardExpiryFieldDelegate <NSObject>
- (void)cardExpiryDidChange:(BTUICardExpiryField *)field;
@end
