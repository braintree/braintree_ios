#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 UI Customization Options for 3D Secure 1 Flows.
 */
@interface BTThreeDSecureV1UICustomization : NSObject

/**
 Optional. Text displayed in the Redirect button after a 3DS1 challenge is completed in the browser.
 */
@property (nonatomic, nullable, copy) NSString *redirectButtonText;

/**
 Optional. Text displayed below the Redirect button after a 3DS1 challenge is completed in the browser.
 */
@property (nonatomic, nullable, copy) NSString *redirectDescription;

@end

NS_ASSUME_NONNULL_END
