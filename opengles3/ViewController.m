//
//  ViewController.m
//  opengles3
//
//  Created by yogi on 2/25/20.
//  Copyright © 2020 yogi. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController{
    CCEAGLView *_eaglView;
}

-(void)loadView {
    float scale = [[UIScreen mainScreen] scale];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds.origin.x = 0;
    bounds.origin.y = 0;
    bounds.size.width *=scale;
    bounds.size.height *=scale;
    NSLog(@"load view is called:%f :%f,%f %f,%f",scale,bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    int multisamplingCount=0;
    BOOL _multiTouch=NO;
    //IDEA: iOS only support these pixel format?
    // - RGB565
    // - RGBA8
    NSString *pixelString = kEAGLColorFormatRGB565;
//        pixelString = kEAGLColorFormatRGBA8;
    
    // create view
    _eaglView = [[CCEAGLView alloc] initWithFrame: bounds];
//                                         pixelFormat: pixelString
//                                         depthFormat: GL_DEPTH24_STENCIL8 //depthFormat2GLDepthFormat(depthFormat)
//                                  preserveBackbuffer: NO
//                                          sharegroup: nil
//                                       multiSampling: multisamplingCount != 0
//                                     numberOfSamples: multisamplingCount];
    self.view=(UIView *)_eaglView;
    [_eaglView setMultipleTouchEnabled:_multiTouch];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"view did loaded");
    // Do any additional setup after loading the view.
    if(NO){
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_eaglView initGL];
    });
    }else{
//        setupGraphics(0,0);

//    [self.eaglview performSelector:@selector(initGL) afterDelay:1];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)1), dispatch_get_main_queue(), ^{
//            [self.eaglview initGL];

        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)3), dispatch_get_main_queue(), ^{
//            [self.view draw1];
            [self.app startMainLoop];
        });
    }
    
    
}

//- (CGPoint)convertPoint:(CGPoint)point
//                 toView:(UIView *)view{
//    if(view==self.eaglview)
//    return point;
//    return point;
//}

- (IBAction)onRotated:(UIRotationGestureRecognizer *)sender {
//    sender.rotation
//    sender.velocity
    CGPoint p=    [sender locationInView:(UIView *)_eaglView];

    NSLog(@"rotate amount:%f vel:%f loc:%f:%f",sender.rotation,sender.velocity,p.x,p.y);
}
- (IBAction)onPaned:(UIPanGestureRecognizer *)sender {
    
    NSLog(@"panned");
    
}

- (void)dealloc {
    [_eaglView release];
    [super dealloc];
}
@end
