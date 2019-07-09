//
//  CardinalImageUrl.h
//  CardinalMobile
//
//  Copyright © 2018 CardinalCommerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*!
 * @interface CardinalImageUrl
 * @brief Image URLs of various sizes.
 */
@interface CardinalImageUrl : NSObject

/*!
 * @property medium Medium Image URL
 * @brief URL for medium sized Image.
 */
@property (nonatomic, readonly) NSString *medium;

/*!
 * @property high High Image URL
 * @brief URL for high sized Image.
 */
@property (nonatomic, readonly) NSString *high;

/*!
 * @property extraHigh Extra High Image URL
 * @brief URL for extra high sized Image.
 */
@property (nonatomic, readonly) NSString *extraHigh;

/*!
 * Get the appropriate sized image url based on the device scale.
 * @return NSString String URL of the image.
 */
-(NSString *)getUrl;

@end
