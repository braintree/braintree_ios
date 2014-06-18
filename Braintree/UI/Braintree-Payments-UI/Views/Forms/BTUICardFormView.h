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

/// Configure whether to support complete alphanumeric postal codes.
///
/// If NO, allows only digit entry.
///
/// Defaults to YES
@property (nonatomic, assign) BOOL alphaNumericPostalCode;

/// Which fields should be included.
///
/// Defaults to BTUICardFormOptionalFieldsAll
@property (nonatomic, assign) BTUICardFormOptionalFields optionalFields;

/// Whether to provide feedback to the user via vibration
///
/// Defaults ot YES
@property (nonatomic, assign) BOOL vibrate;


@end

/// Delegate protocol for receiving updates about the card form
@protocol BTUICardFormViewDelegate <NSObject>

/// The card form data has updated.
- (void)cardFormViewDidChange:(BTUICardFormView *)cardFormView;

@end
