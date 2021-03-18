//
//  CustomWindow.h
//  TouchDemo
//
//  Created by Astha Ameta on 19/08/20.
//  Copyright © 2020 Kount Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomWindowProtocol <NSObject>
-(void)touchesBeganCalledOfWindow:(NSSet<UITouch *> *_Nullable)touches withEvent:(UIEvent *_Nullable)event;
-(void)touchesEndedCalledOfWindow:(NSSet<UITouch *> *_Nullable)touches withEvent:(UIEvent *_Nullable)event;
-(void)touchesMovedCalledOfWindow:(NSSet<UITouch *> *_Nullable)touches withEvent:(UIEvent *_Nullable)event;
@end

NS_ASSUME_NONNULL_BEGIN

@interface CustomWindow : UIWindow

@property(weak, nonatomic) id<CustomWindowProtocol> touchDelegate;

@end

NS_ASSUME_NONNULL_END
