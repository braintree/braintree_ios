//
//  LabelCustomization.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import "Customization.h"

/**
 * The LabelCustomization class provides methods for the 3DS Requestor App to pass label customization parameters to the 3DS SDK.
 */
@interface LabelCustomization : Customization

/**
 * @property headingTextColor Colour code in Hex format. For example, the colour code can be “#999999”.
 */
@property (nonatomic, strong) NSString* headingTextColor;

/**
 * @property headingTextFontName Font type for the heading label text.
 */
@property (nonatomic, strong) NSString* headingTextFontName;

/**
 * @property headingTextFontSize Font size for the heading label text.
 */
@property int headingTextFontSize;

@end
