//
//  UIViewController+TouchControl.m
//  TouchDemo
//
//  Created by Astha Ameta on 19/08/20.
//  Copyright © 2020 Kount Inc. All rights reserved.
//

#import "UIViewController+TouchControl.h"
#import "UIControl+CustomControl.h"
#import <objc/runtime.h>

static void * CustomControlDelegateKey = &CustomControlDelegateKey;

@implementation UIViewController (TouchControl)

-(id<CustomControlDelegate>)touchDelegate {
    return objc_getAssociatedObject(self, CustomControlDelegateKey);
}

- (void)setTouchDelegate:(id<CustomControlDelegate>)touchDelegate {
    objc_setAssociatedObject(self, CustomControlDelegateKey, touchDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.touchDelegate touchBeganCalledWith:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self.touchDelegate touchEndedCalledWith:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    [self.touchDelegate touchMovedCalledWith:touches withEvent:event];
}

@end
