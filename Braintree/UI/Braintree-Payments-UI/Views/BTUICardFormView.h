#import "BTUIThemedView.h"

typedef NS_OPTIONS(NSUInteger, BTUICardFormOptionalFields) {
    BTUICardFormOptionalFieldsNone       = 0,
    BTUICardFormOptionalFieldsCvv        = 1 << 0,
    BTUICardFormOptionalFieldsPostalCode = 1 << 1,
    BTUICardFormOptionalFieldsAll        = BTUICardFormOptionalFieldsCvv | BTUICardFormOptionalFieldsPostalCode
};

@protocol BTUICardFormViewDelegate;

@interface BTUICardFormView : BTUIThemedView

@property (nonatomic, weak) IBOutlet id<BTUICardFormViewDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL valid;
@property (nonatomic, copy, readonly) NSString *number;
@property (nonatomic, copy, readonly) NSString *cvv;
@property (nonatomic, copy, readonly) NSString *expirationMonth;
@property (nonatomic, copy, readonly) NSString *expirationYear;
@property (nonatomic, copy, readonly) NSString *postalCode;

@property (nonatomic, assign) BOOL alphaNumericPostalCode;
@property (nonatomic, assign) BTUICardFormOptionalFields optionalFields;

@end

/// Delegate protocol for receiving updates about the card form
@protocol BTUICardFormViewDelegate <NSObject>

/// The card form data has updated.
- (void)cardFormViewDidChange:(BTUICardFormView *)cardFormView;

@end
