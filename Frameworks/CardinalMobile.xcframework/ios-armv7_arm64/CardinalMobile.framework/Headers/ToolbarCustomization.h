//
//  ToolbarCustomization.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import "Customization.h"

/**
 * The ToolbarCustomization class provides methods for the 3DS Requestor App to pass toolbar customization parameters to the 3DS SDK.
 */
@interface ToolbarCustomization : Customization

/**
 * @property backgroundColor Colour code in Hex format. For example, the colour code can be “#999999”.
 */
@property (nonatomic, strong) NSString* backgroundColor;

/**
 * @property headerText Text for the header.
 */
@property (nonatomic, strong) NSString* headerText;

/**
 * @property buttonText Text for the button. For example, “Cancel”.
 */
@property (nonatomic, strong) NSString* buttonText;

@end
