//
//  AppDelegate.m
//  opengles3
//
//  Created by yogi on 2/25/20.
//  Copyright © 2020 yogi. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"



@interface AppDelegate (){
    id _displayLink;
    int _fps;
    float _systemVersion;
    BOOL _isAppActive;
    //std::shared_ptr<cocos2d::Scheduler> _scheduler;
    ViewController *_viewController;
}


@end

AppDelegate *_application;
ViewController *vc;
//UIWindow *window;

@implementation AppDelegate

-(CCEAGLView *)getView{
    return (CCEAGLView *)vc.view;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_displayLink release];
    
    [super dealloc];
}

- (void)appDidBecomeActive
{
    _isAppActive = YES;
}

- (void)appDidBecomeInactive
{
    _isAppActive = NO;
}

-(void) firstStart:(id) view
{
    if ([view isReady])
    {
        //        auto scheduler = _application->getScheduler();
        //        scheduler->removeAllFunctionsToBePerformedInCocosThread();
        //        scheduler->unscheduleAll();
        
        //        se::ScriptEngine::getInstance()->cleanup();
        //        cocos2d::PoolManager::getInstance()->getCurrentPool()->clear();
        //        cocos2d::EventDispatcher::init();
        
        //        cocos2d::ccInvalidateStateCache();
        //        se::ScriptEngine* se = se::ScriptEngine::getInstance();
        //        se->addRegisterCallback(setCanvasCallback);
        //
        //        if(!_application->applicationDidFinishLaunching())
        //            return;
        
        [self startMainLoop];
    }
    else
        [self performSelector:@selector(firstStart:) withObject:view afterDelay:0];
}

-(void) startMainLoop
{
    [self stopMainLoop];
    
    _displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(doCaller:)];
    if (_systemVersion >= 10.0f)
        [_displayLink setPreferredFramesPerSecond: _fps];
    else
        [_displayLink setFrameInterval: 60 / _fps];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void) stopMainLoop
{
    if (_displayLink != nil)
    {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

-(void) setPreferredFPS:(int)fps
{
    _fps = fps;
    [self startMainLoop];
}

-(void) doCaller: (id) sender
{
    if(NO){
    //    static std::chrono::steady_clock::time_point prevTime;
    //    static std::chrono::steady_clock::time_point now;
    static float dt = 0.f;
    
    //    prevTime = std::chrono::steady_clock::now();
    
    //    bool downsampleEnabled = _application->isDownsampleEnabled();
    //    if (downsampleEnabled)
    //        _application->getRenderTexture()->prepare();
    
    //    _scheduler->update(dt);
    //    cocos2d::EventDispatcher::dispatchTickEvent(dt);
    //
    //    if (downsampleEnabled)
    //        _application->getRenderTexture()->draw();
    
    [(CCEAGLView*)[_application getView] swapBuffers];
    //    cocos2d::PoolManager::getInstance()->getCurrentPool()->clear();
    
    //    now = std::chrono::steady_clock::now();
    //    dt = std::chrono::duration_cast<std::chrono::microseconds>(now - prevTime).count() / 1000000.f;
    }else{
        [(CCEAGLView *)vc.view doLoop];
    }
}
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions API_AVAILABLE(ios(6.0)){
    float scale = [[UIScreen mainScreen] scale];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame: bounds];
    
    //        app->setMultitouch(true);
    
    // Use RootViewController to manage CCEAGLView
    //        _viewController = [[ViewController alloc]init];
    //            //            _viewController=[[ControllerWebView alloc] initWithNibName:@"ControllerWebView" bundle:nil];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _viewController= [sb instantiateInitialViewController];
    //    _viewController= (ViewController *)[sb instantiateViewControllerWithIdentifier:nil];
    vc=_viewController;
#ifdef NSFoundationVersionNumber_iOS_7_0
    _viewController.automaticallyAdjustsScrollViewInsets = NO;
    _viewController.extendedLayoutIncludesOpaqueBars = NO;
    _viewController.edgesForExtendedLayout = UIRectEdgeAll;
#else
    _viewController.wantsFullScreenLayout = YES;
#endif
    _viewController.app=self;
    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [self.window addSubview: _viewController.view];
    }
    else
    {
        // use this method on ios6
        [self.window setRootViewController:_viewController];
    }
    
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _fps = 60;
    _systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    
//    _application = application;
    //        _scheduler = _application->getScheduler();
    
    _isAppActive = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [nc addObserver:self selector:@selector(appDidBecomeInactive) name:UIApplicationWillResignActiveNotification object:nil];
    
//    [self startMainLoop];
    
    return YES;
}


//#pragma mark - UISceneSession lifecycle

//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
