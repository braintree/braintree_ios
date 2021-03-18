//
//  CustomWindow.m
//  TouchDemo
//
//  Created by Astha Ameta on 19/08/20.
//  Copyright © 2020 Kount Inc. All rights reserved.
//

#import "CustomWindow.h"

@implementation CustomWindow

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.touchDelegate touchesBeganCalledOfWindow:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.touchDelegate touchesMovedCalledOfWindow:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.touchDelegate touchesEndedCalledOfWindow:touches withEvent:event];
}

@end
