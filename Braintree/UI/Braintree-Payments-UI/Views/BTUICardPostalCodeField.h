#import "BTUIFormField.h"

@protocol BTUICardPostalCodeFieldDelegate;

@interface BTUICardPostalCodeField : BTUIFormField

@property (nonatomic, weak) id<BTUICardPostalCodeFieldDelegate> delegate;
@property (nonatomic, strong, readonly) NSString *postalCode;
@property (nonatomic, assign) BOOL nonDigitsSupported;

@end

@protocol BTUICardPostalCodeFieldDelegate <NSObject>
- (void)cardPostalCodeDidChange:(BTUICardPostalCodeField *)field;
@end
