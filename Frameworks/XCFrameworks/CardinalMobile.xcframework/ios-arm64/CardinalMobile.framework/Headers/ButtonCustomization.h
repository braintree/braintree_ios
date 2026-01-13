//
//  ButtonCustomization.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import "Customization.h"

/**
 * The ButtonCustomization class provides methods for the 3DS Requestor App to pass button customization parameters to the 3DS SDK.
 */
@interface ButtonCustomization : Customization

/**
 * @property backgroundColor Colour code in Hex format. For example, the colour code can be “#999999”.
 */
@property (nonatomic, strong) NSString* backgroundColor;

/**
 * @property cornerRadius  Radius (integer value) for the button corners.
 */
@property int cornerRadius;

@end
