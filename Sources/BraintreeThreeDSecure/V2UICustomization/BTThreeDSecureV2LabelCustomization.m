#import "BTThreeDSecureV2BaseCustomization_Internal.h"

#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureV2LabelCustomization.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureV2LabelCustomization.h>
#endif

@implementation BTThreeDSecureV2LabelCustomization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cardinalValue = [LabelCustomization new];
    }

    return self;
}

- (void)setHeadingTextColor:(NSString *)headingTextColor {
    _headingTextColor = headingTextColor;
    ((LabelCustomization *)self.cardinalValue).headingTextColor = headingTextColor;
}

- (void)setHeadingTextFontName:(NSString *)headingTextFontName {
    _headingTextFontName = headingTextFontName;
    ((LabelCustomization *)self.cardinalValue).headingTextFontName = headingTextFontName;
}

- (void)setHeadingTextFontSize:(int)headingTextFontSize {
    _headingTextFontSize = headingTextFontSize;
    ((LabelCustomization *)self.cardinalValue).headingTextFontSize = headingTextFontSize;
}

@end
