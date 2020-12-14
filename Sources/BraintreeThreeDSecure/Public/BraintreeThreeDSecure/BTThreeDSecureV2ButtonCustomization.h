//
//  BTThreeDSecureV2ButtonCustomization.h
//  BraintreeThreeDSecure
//
//  Created by Cannillo, Sammy on 12/14/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The ButtonCustomization class provides methods for the 3DS Requestor App to pass button customization parameters to the 3DS SDK.
 */
@interface BTThreeDSecureV2ButtonCustomization : NSObject

/**
 * @property backgroundColor Colour code in Hex format. For example, the colour code can be “#999999”.
 */
@property (nonatomic, strong) NSString* backgroundColor;

/**
 * @property cornerRadius  Radius (integer value) for the button corners.
 */
@property int cornerRadius;

@end

NS_ASSUME_NONNULL_END
