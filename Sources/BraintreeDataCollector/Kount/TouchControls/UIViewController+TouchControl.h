//
//  UIViewController+TouchControl.h
//  TouchDemo
//
//  Created by Astha Ameta on 19/08/20.
//  Copyright © 2020 Kount Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIControl+CustomControl.h"

@protocol CustomControlDelegate <NSObject>
-(void)touchBeganCalledWith:(NSSet<UITouch *> *_Nullable)touches withEvent:(UIEvent *_Nullable)event;
-(void)touchMovedCalledWith:(NSSet<UITouch *> *_Nullable)touches withEvent:(UIEvent *_Nullable)event;
-(void)touchEndedCalledWith:(NSSet<UITouch *> *_Nullable)touches withEvent:(UIEvent *_Nullable)event;
// ... other methods here
@end

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (TouchControl)

@property (nonatomic, strong) id<CustomControlDelegate> touchDelegate;

@end

NS_ASSUME_NONNULL_END
