//
//  AppDelegate.h
//  opengles3
//
//  Created by yogi on 2/25/20.
//  Copyright © 2020 yogi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCEAGLView;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic,retain) UIWindow *window;

-(CCEAGLView *)getView;
-(void) startMainLoop;
-(void) stopMainLoop;
-(void) doCaller: (id) sender;
-(void) setPreferredFPS:(int)fps;
-(void) firstStart:(id) view;

@end

