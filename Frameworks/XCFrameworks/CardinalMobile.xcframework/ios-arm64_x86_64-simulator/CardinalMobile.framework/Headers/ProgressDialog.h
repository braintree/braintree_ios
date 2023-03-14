//
//  ProgressDialog.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The processing screen that displays the Directory Server logo, and a graphical element to indicate that an activity is being processed.
 */
@interface ProgressDialog : NSObject

- (void) start;

- (void) stop;

@end
