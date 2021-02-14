//
//  CCEAGLView.m
//  opengles3
//
//  Created by yogi on 2/25/20.
//  Copyright © 2020 yogi. All rights reserved.
//
#define GLES_SILENCE_DEPRECATION
#import "CCEAGLView.h"

//@implementation CCEAGLView
//
///*
//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}
//*/
//
//@end

/*
 
 ===== IMPORTANT =====
 
 This is sample code demonstrating API, technology or techniques in development.
 Although this sample code has been reviewed for technical accuracy, it is not
 final. Apple is supplying this information to help you plan for the adoption of
 the technologies and programming interfaces described herein. This information
 is subject to change, and software implemented based on this sample code should
 be tested with final operating system software and final documentation. Newer
 versions of this sample code may be provided with future seeds of the API or
 technology. For information about updates to this and other developer
 documentation, view the New & Updated sidebars in subsequent documentation
 seeds.
 
 =====================
 
 File: EAGLView.m
 Abstract: Convenience class that wraps the CAEAGLLayer from CoreAnimation into a
 UIView subclass.
 
 Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2008 Apple Inc. All Rights Reserved.
 
 */


//#include "scripting/js-bindings/event/EventDispatcher.h"
//#include "platform/ios/OpenGL_Internal-ios.h"
/* Generic error reporting */
#define REPORT_ERROR(__FORMAT__, ...) printf("%s: %s\n", __FUNCTION__, [[NSString stringWithFormat:__FORMAT__, __VA_ARGS__] UTF8String])

/* EAGL and GL functions calling wrappers that log on error */
#define CALL_EAGL_FUNCTION(__FUNC__, ...) ({ EAGLError __error = __FUNC__( __VA_ARGS__ ); if(__error != kEAGLErrorSuccess) printf("%s() called from %s returned error %i\n", #__FUNC__, __FUNCTION__, __error); (__error ? NO : YES); })
//#define CHECK_GL_ERROR() ({ GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s\n", __error, __FUNCTION__); (__error ? NO : YES); })
#define CHECK_GL_ERROR() ({ GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); })


/* Optional delegate methods support */
#ifndef __DELEGATE_IVAR__
#define __DELEGATE_IVAR__ _delegate
#endif
#ifndef __DELEGATE_METHODS_IVAR__
#define __DELEGATE_METHODS_IVAR__ _delegateMethods
#endif
#define TEST_DELEGATE_METHOD_BIT(__BIT__) (self->__DELEGATE_METHODS_IVAR__ & (1 << __BIT__))
#define SET_DELEGATE_METHOD_BIT(__BIT__, __NAME__) { if([self->__DELEGATE_IVAR__ respondsToSelector:@selector(__NAME__)]) self->__DELEGATE_METHODS_IVAR__ |= (1 << __BIT__); else self->__DELEGATE_METHODS_IVAR__ &= ~(1 << __BIT__); }



//#include "platform/CCApplication.h"
//#include "base/ccMacros.h"
//#include "ui/edit-box/EditBox.h"

//this is old. newer one is GLView which is still old. newer one is metal.

namespace
{
#ifdef OPENGLES_2
GLenum pixelformat2glenum(NSString* str)
{
    if ([str isEqualToString:kEAGLColorFormatRGB565])
        return GL_RGB565;
    //        return GL_RGBA8;
    else
        return 0;//GL_RGBA8_OES;
}
#endif
}

//CLASS IMPLEMENTATIONS:

#define MAX_TOUCH_COUNT     10

@interface CCEAGLView (Private)
@end

@implementation CCEAGLView

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}


- (id) initWithFrame:(CGRect)frame
//         pixelFormat:(NSString*)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained sharegroup:(EAGLSharegroup*)sharegroup multiSampling:(BOOL)sampling numberOfSamples:(unsigned int)nSamples
{
    if((self = [super initWithFrame:frame]))
    {
        NSString *pixelString = kEAGLColorFormatRGB565;
        //        pixelString = kEAGLColorFormatRGBA8;
        NSString*format=pixelString;
        GLuint depth=GL_DEPTH24_STENCIL8;//GL_DEPTH24_STENCIL8_OES;
        BOOL retained=NO; //preserveBackBuffer
        EAGLSharegroup*sharegroup=nil;
        unsigned int nSamples=0;
        BOOL sampling=nSamples!=0;
        
        _pixelformatString = format;
#ifdef OPENGLES_2
        _pixelformat = pixelformat2glenum(_pixelformatString);
#endif
        _depthFormat = depth;
        // Multisampling doc: https://developer.apple.com/library/content/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithEAGLContexts/WorkingwithEAGLContexts.html#//apple_ref/doc/uid/TP40008793-CH103-SW4
        _multisampling = sampling;
        _requestedSamples = nSamples;
        _preserveBackbuffer = retained;
        _sharegroup = sharegroup;
        _isReady = FALSE;
        _needToPreventTouch = FALSE;
        
#if GL_EXT_discard_framebuffer == 1
        _discardFramebufferSupported = YES;
#else
        _discardFramebufferSupported = NO;
#endif
        if ([self respondsToSelector:@selector(setContentScaleFactor:)])
            self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        _touchIds = 0;
        for (int i = 0; i < 10; ++i)
        _touches[i] = nil;
        
        [self setupGLContext];
    }
    
    return self;
    
}



- (void) dealloc
{
    [self releaseCtx];
    [super dealloc];
}
-(void)releaseCtx{
    if (_defaultColorBuffer)
    {
        glDeleteRenderbuffers(1, &_defaultColorBuffer);
        _defaultColorBuffer = 0;
    }
    
    if (_defaultDepthBuffer)
    {
        glDeleteRenderbuffers(1, &_defaultDepthBuffer);
        _defaultDepthBuffer = 0;
    }
    
    if (_defaultFramebuffer)
    {
        glDeleteFramebuffers(1, &_defaultFramebuffer);
        _defaultFramebuffer = 0;
    }
    
    if (_msaaColorBuffer)
    {
        glDeleteRenderbuffers(1, &_msaaColorBuffer);
        _msaaColorBuffer = 0;
    }
    
    if (_msaaDepthBuffer)
    {
        glDeleteRenderbuffers(1, &_msaaDepthBuffer);
        _msaaDepthBuffer = 0;
    }
    
    if (_msaaFramebuffer)
    {
        glDeleteFramebuffers(1, &_msaaFramebuffer);
        _msaaFramebuffer = 0;
    }
    
    if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    
    if (_context)
    {
        [_context release];
        _context = nil;
    }
    
}
//the property
//-(void)setCBonReady:(void (^)())b{
//    //self.onReady=b; //recursive!
//    CBonReady=b;
//    [CBonReady retain];
//}


- (void) layoutSubviews
{ NSLog(@"eagl do layout");
    /*
     the new version on github have this check.
     and they have realized that framebufer might be in invalid state.
     */
    UIApplicationState state=[UIApplication sharedApplication].applicationState;
    if(state== UIApplicationStateBackground)
        return;
    //    [self initGL];
    
    
    GLint oldFBO;
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    if (_defaultColorBuffer)
    {
        glBindRenderbuffer(GL_RENDERBUFFER, _defaultColorBuffer);
        if(! [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer])
        {
            NSLog(@"failed to call context");
            return;
        }
    }
    
    int backingWidth = 0;
    int backingHeight = 0;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    CGRect b= [[UIScreen mainScreen] bounds];
    int scale=[UIScreen mainScreen].scale;
    CGRect sb;
    NSLog(@"backing %d:%d",backingWidth,backingHeight);
    if(backingWidth!=b.size.width*scale || backingHeight!=b.size.height*scale){
        UIView *sv=self.superview;
        CGRect sf=sv.frame, f2=self.frame;
        b=self.layer.bounds;  sb=self.layer.superlayer.bounds;
        NSLog(@"frame not right,FB:%d CB:%d frame:%f:%f %f:%f -> %f:%f %f:%f",_defaultFramebuffer,_defaultColorBuffer,sf.origin.x,sf.origin.y,sf.size.width,sf.size.height,f2.origin.x,f2.origin.y,f2.size.width,f2.size.height);
        NSLog(@"bounds:%f:%f %f:%f -> %f:%f %f:%f",sb.origin.x,sb.origin.y,sb.size.width,sb.size.height,b.origin.x,b.origin.y,b.size.width,b.size.height);
        sb=CGRectMake(sb.origin.x,sb.origin.y ,sb.size.width*scale ,sb.size.height*scale );
    }else{
        sb=CGRectMake(0, 0, b.size.width*scale, b.size.height*scale);
    }
    //  glViewport(sb.origin.x, sb.origin.y, sb.size.width, sb.size.height);
    
    if (_defaultDepthBuffer)
    {
        glBindRenderbuffer(GL_RENDERBUFFER, _defaultDepthBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, _depthFormat, backingWidth, backingHeight);
    }
    
    if (_multisampling)
    {
#ifdef OPENGLES_2
        glBindFramebuffer(GL_FRAMEBUFFER, _msaaFramebuffer);
        if (_msaaColorBuffer)
        {
            glBindRenderbuffer(GL_RENDERBUFFER, _msaaColorBuffer);
            glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, _requestedSamples, _pixelformat, backingWidth, backingHeight);
        }
        
        if (_msaaDepthBuffer)
        {
            glBindRenderbuffer(GL_RENDERBUFFER, _msaaDepthBuffer);
            glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, _requestedSamples, _depthFormat, backingWidth, backingHeight);
        }
#endif
    }
    else
    {
        glBindRenderbuffer(GL_RENDERBUFFER, _defaultColorBuffer);
    }
    
    CHECK_GL_ERROR();
    
    GLenum error;
    if( (error=glCheckFramebufferStatus(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE){
        NSLog(@"Failed to make complete framebuffer object 0x%X", error);
        return;
    }
    _isReady = TRUE;
    //void ^(o)()=self.CBonReady;
    //    if(_CBonReady){
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            _CBonReady();
    //        });
    //    }
}
- (BOOL) isReady
{
    return _isReady;
}

-(void) setPreventTouchEvent:(BOOL) flag
{
    _needToPreventTouch = flag;
}

- (void) setupGLContext
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:_preserveBackbuffer], kEAGLDrawablePropertyRetainedBacking,
                                    _pixelformatString, kEAGLDrawablePropertyColorFormat, nil];
    
    if(! _sharegroup)
    {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (!_context)
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    else
    {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3 sharegroup:_sharegroup];
        if (!_context)
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:_sharegroup];
    }
    if(    _context){
        NSLog(@"OpenGL ES API:%lu",        (unsigned long)_context.API);
        if (![EAGLContext setCurrentContext:_context] ) {
            NSLog(@"Can not crate GL context.");
            return;
        }
    }else{
        return;
    }
    
    
    if (![self createFrameBuffer])
        return;
    if (![self createAndAttachColorBuffer])
        return;
    
    [self createAndAttachDepthBuffer];
}

- (BOOL) createFrameBuffer
{
    if (!_context)
        return FALSE;
    
    glGenFramebuffers(1, &_defaultFramebuffer);
    if (0 == _defaultFramebuffer)
    {
        NSLog(@"Can not create default frame buffer.");
        return FALSE;
    }
    
    if (_multisampling)
    {
        glGenFramebuffers(1, &_msaaFramebuffer);
        if (0 == _msaaFramebuffer)
        {
            NSLog(@"Can not create multi sampling frame buffer");
            _multisampling = FALSE;
        }
    }
    
    return TRUE;
}

- (BOOL) createAndAttachColorBuffer
{
    if (0 == _defaultFramebuffer)
        return FALSE;
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glGenRenderbuffers(1, &_defaultColorBuffer);
    if (0 == _defaultColorBuffer)
    {
        NSLog(@"Can not create default color buffer.");
        return FALSE;
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, _defaultColorBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _defaultColorBuffer);
    CHECK_GL_ERROR();
    
    if (!_multisampling || (0 == _msaaFramebuffer))
        return TRUE;
    
    glBindFramebuffer(GL_FRAMEBUFFER, _msaaFramebuffer);
    glGenRenderbuffers(1, &_msaaColorBuffer);
    if (0 == _msaaColorBuffer)
    {
        NSLog(@"Can not create multi sampling color buffer.");
        
        // App can work without multi sampleing.
        return TRUE;
    }
    glBindRenderbuffer(GL_RENDERBUFFER, _msaaColorBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _msaaColorBuffer);
    CHECK_GL_ERROR();
    return TRUE;
}

- (BOOL) createAndAttachDepthBuffer
{
    if (0 == _defaultFramebuffer || 0 == _depthFormat)
        return FALSE;
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glGenRenderbuffers(1, &_defaultDepthBuffer);
    if (0 == _defaultDepthBuffer)
    {
        NSLog(@"Can not create default depth buffer.");
        return FALSE;
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, _defaultDepthBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _defaultDepthBuffer);
    CHECK_GL_ERROR();
#ifdef OPENGLES_2
    if (GL_DEPTH24_STENCIL8_OES == _depthFormat ||
        GL_DEPTH_STENCIL_OES == _depthFormat)
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _defaultDepthBuffer);
#endif
    CHECK_GL_ERROR();
    
    if (!_multisampling || (0 == _msaaFramebuffer))
        return TRUE;
    
    glBindFramebuffer(GL_FRAMEBUFFER, _msaaFramebuffer);
    glGenRenderbuffers(1, &_msaaDepthBuffer);
    if (0 == _msaaDepthBuffer)
    {
        NSLog(@"Can not create multi sampling depth buffer.");
        return TRUE;
    }
    glBindRenderbuffer(GL_RENDERBUFFER, _msaaDepthBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _msaaDepthBuffer);
    CHECK_GL_ERROR();
#ifdef OPENGLES_2
    if (GL_DEPTH24_STENCIL8_OES == _depthFormat ||
        GL_DEPTH_STENCIL_OES == _depthFormat)
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _msaaDepthBuffer);
#endif
    CHECK_GL_ERROR();
    
    return TRUE;
}

- (void) swapBuffers
{
    // IMPORTANT:
    // - preconditions
    //    -> context_ MUST be the OpenGL context
    //    -> renderbuffer_ must be the RENDER BUFFER
    
    //    if (_multisampling)
    //    {
    //        /* Resolve from msaaFramebuffer to resolveFramebuffer */
    //        //glDisable(GL_SCISSOR_TEST);
    //        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _msaaFramebuffer);
    //        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _defaultFramebuffer);
    //        glResolveMultisampleFramebufferAPPLE();
    //    }
    
    CHECK_GL_ERROR();
#ifdef OPENGLES_2
    if (_discardFramebufferSupported)
    {
        //        if (_multisampling)
        //        {
        //            if (_depthFormat)
        //            {
        //                GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
        //                glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
        //            }
        //            else
        //            {
        //                GLenum attachments[] = {GL_COLOR_ATTACHMENT0};
        //                glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, attachments);
        //            }
        //
        //
        //        }
        //        else if (_depthFormat)
        //        {
        //            // not MSAA
        //            GLenum attachments[] = { GL_DEPTH_ATTACHMENT};
        //            glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, attachments);
        //        }
        
    }
#else
    //    GLenum attachments[] = { GL_DEPTH_ATTACHMENT};
    //    glInvalidateFramebuffer(GL_FRAMEBUFFER, 1, attachments);
#endif
    CHECK_GL_ERROR();
    
    glBindRenderbuffer(GL_RENDERBUFFER, _defaultColorBuffer);
    
    if(![_context presentRenderbuffer:GL_RENDERBUFFER])
        NSLog(@"cocos2d: Failed to swap renderbuffer in %s\n", __FUNCTION__);
    
    CHECK_GL_ERROR();
    
    // We can safely re-bind the framebuffer here, since this will be the
    // 1st instruction of the new main loop
    if(_multisampling)
        glBindFramebuffer(GL_FRAMEBUFFER, _msaaFramebuffer);
}

// Pass the touches to the superview
//#pragma mark CCEAGLView - Touch Delegate

//namespace
//{
//    int getUnusedID(unsigned int& touchIDs)
//    {
//        int i;
//        unsigned int temp = touchIDs;
//
//        for (i = 0; i < 10; i++) {
//            if (! (temp & 0x00000001))
//            {
//                touchIDs |= (1 <<  i);
//                return i;
//            }
//
//            temp >>= 1;
//        }
//
//        // all bits are used
//        return -1;
//    }
//
//    void resetTouchID(unsigned int& touchIDs, int index)
//    {
//        touchIDs &= ((1 << index) ^ 0xffffffff);
//    }
//
//    cocos2d::TouchInfo createTouchInfo(int index, UITouch* touch, float contentScaleFactor)
//    {
//        uint8_t deviceRatio = cocos2d::Application::getInstance()->getDevicePixelRatio();
//        cocos2d::TouchInfo touchInfo;
//        touchInfo.index = index;
//        touchInfo.x = [touch locationInView: [touch view]].x * contentScaleFactor / deviceRatio;
//        touchInfo.y = [touch locationInView: [touch view]].y * contentScaleFactor / deviceRatio;
//
//        return touchInfo;
//    }
//
//    void deliverTouch(cocos2d::TouchEvent& touchEvent,
//                      NSSet* touches,
//                      UITouch** internalTouches,
//                      float contentScaleFactor,
//                      bool reset,
//                      unsigned int& touchIds)
//    {
//        for (UITouch *touch in touches)
//        {
//            for (int i = 0; i < MAX_TOUCH_COUNT; ++i)
//            {
//                if (touch == internalTouches[i])
//                {
//                    if (reset)
//                    {
//                        internalTouches[i] = nil;
//                        resetTouchID(touchIds, i);
//                    }
//                    touchEvent.touches.push_back(createTouchInfo(i, touch, contentScaleFactor));
//                }
//            }
//        }
//
//        if (!touchEvent.touches.empty())
//            cocos2d::EventDispatcher::dispatchTouchEvent(touchEvent);
//    }
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    // When editbox is editing, should prevent glview to handle touch events.
//    if (_needToPreventTouch)
//    {
//        cocos2d::EditBox::complete();
//        return;
//    }
//
//    cocos2d::TouchEvent touchEvent;
//    touchEvent.type = cocos2d::TouchEvent::Type::BEGAN;
//    for (UITouch *touch in touches) {
//        int index = getUnusedID(_touchIds);
//        if (-1 == index)
//            return;
//
//        _touches[index] = touch;
//
//        touchEvent.touches.push_back(createTouchInfo(index, touch, self.contentScaleFactor));
//    }
//
//    if (!touchEvent.touches.empty())
//        cocos2d::EventDispatcher::dispatchTouchEvent(touchEvent);
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    cocos2d::TouchEvent touchEvent;
//    touchEvent.type = cocos2d::TouchEvent::Type::MOVED;
//    deliverTouch(touchEvent, touches, _touches, self.contentScaleFactor, false, _touchIds);
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    cocos2d::TouchEvent touchEvent;
//    touchEvent.type = cocos2d::TouchEvent::Type::ENDED;
//    deliverTouch(touchEvent, touches, _touches, self.contentScaleFactor, true, _touchIds);
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    cocos2d::TouchEvent touchEvent;
//    touchEvent.type = cocos2d::TouchEvent::Type::CANCELLED;
//    deliverTouch(touchEvent, touches, _touches, self.contentScaleFactor, true, _touchIds);
//}


- (CGPoint)convertPoint:(CGPoint)point
                 toView:(UIView *)view{
    //    if(view==self.eaglview)
    //    return point;
    return point;
}
float vertices[] = {
    -0.5f, -0.5f, 0.0f,
    0.5f, -0.5f, 0.0f,
    0.0f,  0.5f, 0.0f
};

-(void)draw1{
    NSLog(@"draw #1 is called");
    if(YES)
        return;
    
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
    const char *vertexShaderSource =
    //    "#version 330 core\n"
    //    "#version 300 core\n"
    "#version 300 es\n"
    "layout (location = 0) in vec3 aPos;\n"
    "void main()\n"
    "{\n"
    "   gl_Position =vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
    "}\0";
    unsigned int vertexShader;
    vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    glCompileShader(vertexShader);
    int  success;
    char infoLog[512];
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    if(!success)
    {
        glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
        NSLog(@"ERROR::SHADER::VERTEX::COMPILATION_FAILED:%s",infoLog);
    }
    /* GLSL ES 3.0 removes the gl_FragData and gl_FragColor builtin fragment output variables.
     Instead, you declare your own fragment output variables with the out qualifier.
     */
    const char *fragmentShaderSource=
    //    "#version 330 core\n"
    //    "#version 300 core\n\n"
    "#version 300 es\n\n"
    "out mediump vec4 FragColor;\n"
    "void main()\n"
    "{\n"
    "    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
    "}";
    unsigned int fragmentShader;
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    glCompileShader(fragmentShader);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    if(!success)
    {
        glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
        NSLog(@"ERROR::SHADER::fragment::COMPILATION_FAILED:%s",infoLog);
    }
    shaderProgram = glCreateProgram();
    
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    
    
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if(!success) {
        glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
        NSLog(@"ERROR::SHADER::link::%s",infoLog);
    }
    glUseProgram(shaderProgram);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    //layout is 0 in the vertex shader
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    //    glGenVertexArrays(1, &VAO);
    
    // 0. copy our vertices array in a buffer for OpenGL to use
    //    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    //    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    //    // 1. then set the vertex attributes pointers
    //    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    //    glEnableVertexAttribArray(0);
    //    // 2. use our shader program when we want to render an object
    //    glUseProgram(shaderProgram);
    // 3. now draw the object
    //    someOpenGLFunctionThatDrawsOurTriangle();
    
    
    
    // ..:: Initialization code (done once (unless your object frequently changes)) :: ..
    // 1. bind Vertex Array Object
    //    glBindVertexArray(VAO);
    // 2. copy our vertices array in a buffer for OpenGL to use
    //    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    //    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    //    // 3. then set our vertex attributes pointers
    //    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    //    glEnableVertexAttribArray(0);
    
    
    //    [...]
    // ..:: Drawing code (in render loop) :: ..
    // 4. draw the object
    //    glUseProgram(shaderProgram);
    //    glBindVertexArray(VAO);
    //    someOpenGLFunctionThatDrawsOurTriangle();
    
    
    
    
    
}
BOOL inited=NO;
-(void)doLoop{
    if(inited) return;
    //    NSLog(@"doLoop is called"); //indeed called
    if(NO){ //nothing shown
        if(inited){
        }else{
            glGenBuffers(1, &VBO);
            glBindBuffer(GL_ARRAY_BUFFER, VBO);
            glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
            
            
            const char *vertexShaderSource =
            //    "#version 330 core\n"
            //    "#version 300 core\n"
            "#version 300 es\n"
            "layout (location = 0) in vec3 aPos;\n"
            "void main()\n"
            "{\n"
            "   gl_Position =vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
            "}\0";
            unsigned int vertexShader;
            vertexShader = glCreateShader(GL_VERTEX_SHADER);
            glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
            glCompileShader(vertexShader);
            int  success;
            char infoLog[512];
            glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
            if(!success)
            {
                glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
                NSLog(@"ERROR::SHADER::VERTEX::COMPILATION_FAILED:%s",infoLog);
            }
            /* GLSL ES 3.0 removes the gl_FragData and gl_FragColor builtin fragment output variables.
             Instead, you declare your own fragment output variables with the out qualifier.
             */
            const char *fragmentShaderSource=
            //    "#version 330 core\n"
            //    "#version 300 core\n\n"
            "#version 300 es\n\n"
            "out mediump vec4 FragColor;\n"
            "void main()\n"
            "{\n"
            "    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
            "}";
            unsigned int fragmentShader;
            fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
            glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
            glCompileShader(fragmentShader);
            glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
            if(!success)
            {
                glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
                NSLog(@"ERROR::SHADER::fragment::COMPILATION_FAILED:%s",infoLog);
            }
            shaderProgram = glCreateProgram();
            
            glAttachShader(shaderProgram, vertexShader);
            glAttachShader(shaderProgram, fragmentShader);
            glLinkProgram(shaderProgram);
            
            
            glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
            if(!success) {
                glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
                NSLog(@"ERROR::SHADER::link::%s",infoLog);
            }
            glUseProgram(shaderProgram);
            glDeleteShader(vertexShader);
            glDeleteShader(fragmentShader);
            
            //layout is 0 in the vertex shader
            glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
            glEnableVertexAttribArray(0);
            inited=YES;
        }
        // 0. copy our vertices array in a buffer for OpenGL to use
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        // 1. then set the vertex attributes pointers
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(0);
        // 2. use our shader program when we want to render an object
        glUseProgram(shaderProgram);
        // 3. now draw the object
        glDrawArrays(GL_TRIANGLES, 0, 3);
        //        someOpenGLFunctionThatDrawsOurTriangle();
    }else if(NO){
        [self caseAAA_0 ]; //was good.
    }else if(NO){
        glUseProgram(shaderProgram);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        //    glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
    }else if(NO){
        [self caseAAA]; //good
    }else if(YES){ //based on case AAA
        [self case_rect];
    }
}
-(void)case_rect{
    unsigned int texture1;
    
    if(inited){
        //            return; //the triagle is always there, does not disapper.
    }else{
        float scale = [[UIScreen mainScreen] scale];
        CGRect bounds = [[UIScreen mainScreen] bounds];
        bounds.origin.x = 0;
        bounds.origin.y = 0;
        bounds.size.width *=scale;
        bounds.size.height *=scale;
        NSLog(@"view scale:%f rect:%f,%f %f,%f",scale,bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
        
        //            int x=0,y=0,width=480, height=800;
        int x=bounds.origin.x,y=bounds.origin.y,width=bounds.size.width, height=bounds.size.height;
        glViewport(x, y, width, height);
        //       https://www.khronos.org/registry/OpenGL/specs/es/3.0/GLSL_ES_Specification_3.00.pdf
        //        https://www.khronos.org/registry/OpenGL/specs/es/3.1/GLSL_ES_Specification_3.10.withchanges.pdf
        
        const char *vertexShaderSource = "#version 300 es\n\n" //"#version 330 core\n"
        "layout (location = 0) in vec3 aPos;\n"
        "layout (location = 1) in vec2 aTexCoord;\n"
        "out mediump vec2 TexCoord;\n"
        "void main()\n"
        "{\n"
        "   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
        "   TexCoord = aTexCoord;\n"
        "}\0";
        const char *fragmentShaderSource = "#version 300 es\n\n" //"#version 330 core\n"
        //            "precision highp float;\n"
        //            "out vec4 FragColor;\n" //ERROR::SHADER::FRAGMENT::COMPILATION_FAILED:ERROR: 0:3: 'vec4' : declaration must include a precision qualifier for type
        //            "out vec4f FragColor;\n" //ERROR::SHADER::FRAGMENT::COMPILATION_FAILED:ERROR: 0:3: 'FragColor' : syntax error: syntax error
        //            "out vec4f FragColor;\n" //?
        "out mediump vec4 FragColor;\n"
        "in mediump vec2 TexCoord;\n"
        "uniform sampler2D ourTexture;"
        "void main()\n"
        "{\n"
        "   FragColor = texture(ourTexture, TexCoord);" //vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
        "}\n\0";
        
        // build and compile our shader program
        // ------------------------------------
        // vertex shader
        unsigned int vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
        glCompileShader(vertexShader);
        // check for shader compile errors
        int success;
        char infoLog[512];
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
            NSLog(@"ERROR::SHADER::VERTEX::COMPILATION_FAILED:%s",infoLog);
            return;
        }
        // fragment shader
        unsigned int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
        glCompileShader(fragmentShader);
        // check for shader compile errors
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
            NSLog(@"ERROR::SHADER::FRAGMENT::COMPILATION_FAILED:%s",infoLog);
            return;
        }
        // link shaders
        //unsigned int
        shaderProgram = glCreateProgram();
        glAttachShader(shaderProgram, vertexShader);
        glAttachShader(shaderProgram, fragmentShader);
        glLinkProgram(shaderProgram);
        // check for linking errors
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
        if (!success) {
            glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
            NSLog(@"ERROR::SHADER::PROGRAM::LINKING_FAILED:%s",infoLog);
            return;
        }
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        
        // set up vertex data (and buffer(s)) and configure vertex attributes
        // ------------------------------------------------------------------
        float vertices[] = {
            // positions            // texture coords
            1.0f,  1.0f, 0.0f,   1.0f, 1.0f, // top right
            1.0f, -1.0f, 0.0f,   1.0f, 0.0f, // bottom right
            -1.0f, -1.0f, 0.0f,   0.0f, 0.0f, // bottom left
            -1.0f,  1.0f, 0.0f,   0.0f, 1.0f  // top left
        };
        unsigned int indices[] = {
            0, 1, 3 // first triangle
            ,1, 2, 3  // second triangle
        };
        
        //            unsigned int VBO, VAO;
        unsigned int EBO;
        glGenVertexArrays(1, &VAO);
        glGenBuffers(1, &VBO);
        glGenBuffers(1, &EBO);
        // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
        glBindVertexArray(VAO);
        
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
        
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
        glEnableVertexAttribArray(1);
        
        // texture 1
        // ---------
        glGenTextures(1, &texture1);
        glBindTexture(GL_TEXTURE_2D, texture1);
        
        // set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);    // set texture wrapping to GL_REPEAT (default wrapping method)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        // set texture filtering parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);//GL_LINEAR); //GL_NEAREST
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        NSString *fileName=@"LaunchScreenBackground.png"; //@"wall.jpg";//
        UIImage * img=[UIImage imageNamed:fileName];
        if (!img) {
            NSLog(@"Failed to load image %@", fileName);
            exit(1); //return; //
        }
        UIImageOrientation o=img.imageOrientation;
        CGImageRef spriteImage = img.CGImage;
        // 2
        width = CGImageGetWidth(spriteImage); //750
        height = CGImageGetHeight(spriteImage); //1334
//        img = [UIImage imageWithCGImage: img.CGImage scale: 1.0f orientation: UIImageOrientationDownMirrored]; //neither UIImageOrientationDown nor UIImageOrientationDownMirrored //not able to flip the image.
//        img=[self flipY:img width:width height:height];
//        spriteImage = img.CGImage;
        
        CGColorSpaceRef csr=CGImageGetColorSpace(spriteImage);
        //        CGColorSpace cs=*csr;
        CGBitmapInfo bm=CGImageGetBitmapInfo(spriteImage); //5?
        //kCGBitmapAlphaInfoMask = 0x1F
        //kCGBitmapFloatComponents = (1 << 8)
        //kCGImageByteOrder16Little = (1 << 12)
        //etc  kCGImageByteOrder16Big = (3 << 12)
        size_t bits=CGImageGetBitsPerComponent(spriteImage); //8
        size_t bytes=CGImageGetBytesPerRow(spriteImage); //3000
        CGImageAlphaInfo ai= CGImageGetAlphaInfo(spriteImage); //kCGImageAlphaNoneSkipLast
        //kCGImageAlphaFirst
        //kCGImageAlphaNoneSkipLast
        kCGImageAlphaNone==ai;
        
        
        
        GLubyte * spriteData = (GLubyte *) calloc(bytes*height, sizeof(GLubyte));
        
        CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, bits,
                                                           bytes,
                                                           csr,
                                                           bm); //kCGImageAlphaPremultipliedLast
        
        // 3
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
        [self flipYdata:spriteData width:width height:height];
        for(int i=0;i<20;i+=4){
            NSLog(@"%d,%d,%d,%d",spriteData[i],spriteData[i+1],spriteData[i+2],spriteData[i+3]);
        }
//        27,20,74,255
//        2021-02-06 20:34:05.984477 opengles3[1287:102268] 8,0,59,255
//        2021-02-06 20:34:05.984529 opengles3[1287:102268] 16,8,67,255
//        2021-02-06 20:34:05.984745 opengles3[1287:102268] 15,7,66,255
//        2021-02-06 20:34:05.985241 opengles3[1287:102268] 7,2,60,255
//        60,17,24,255  this is not right.
//        2021-02-06 21:01:55.572637 opengles3[1316:106673] 51,2,12,255
//        2021-02-06 21:01:55.572686 opengles3[1316:106673] 54,3,13,255
//        2021-02-06 21:01:55.572729 opengles3[1316:106673] 51,0,10,255
//        2021-02-06 21:01:55.572896 opengles3[1316:106673] 49,0,7,255
        
        // 4
        
        //            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, spriteData); works, but not good.
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, //border must be 0
//                     GL_RGBA_INTEGER, GL_UNSIGNED_BYTE, spriteData);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, //border must be 0
                     GL_RGBA, GL_UNSIGNED_BYTE, spriteData);

        CGContextRelease(spriteContext);
        free(spriteData);
        //                glGenerateMipmap(GL_TEXTURE_2D);
        
        // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
        // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
        glBindVertexArray(0);
        inited=YES;
        
        // uncomment this call to draw in wireframe polygons.
        //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
//        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
    }
    // render loop
    // -----------
//                while (YES)
    {
        // input
        // -----
        //                processInput(window);
        
        // render
        // ------
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture1);
        
        // draw our first triangle
        glUseProgram(shaderProgram);
        glBindVertexArray(VAO); // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
        //        glDrawArrays(GL_TRIANGLES, 0, 3);
        //glDrawElements(GLenum mode, <#GLsizei count#>, <#GLenum type#>, <#const GLvoid *indices#>)
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        // glBindVertexArray(0); // no need to unbind it every time
        
        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        // -------------------------------------------------------------------------------
        [self swapBuffers];
        //                glfwSwapBuffers(window);
        //                glfwPollEvents();
    }
    
    
    
}
- (void)flipYdata:(GLubyte  *)data width:(int) width height:(int)height{
    int bytes=width<<2;
    GLubyte t[bytes];
    for(int i=0,j=height-2;i<j;i++,j--){
        GLubyte *p_i=data+bytes*i;
        GLubyte *p_j=data+bytes*j;
        memcpy(t,p_i,bytes);
        memcpy(p_i, p_j, bytes);
        memcpy(p_j, t, bytes);
    }
}

- (UIImage *)flipY:(UIImage *)img width:(int) width height:(int)height{
    UIGraphicsBeginImageContext(CGSizeMake(width,height));
    NSLog(@"size %d,%d", width,height);
    CGContextRef context = UIGraphicsGetCurrentContext();

//    if(axis == MVImageFlipXAxis){
//        // Do nothing, X is flipped normally in a Core Graphics Context
//    } else if(axis == MVImageFlipYAxis){
        // fix X axis
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, 1.0f, -1.0f);

        // then flip Y axis
        CGContextTranslateCTM(context, width, 0);
        CGContextScaleCTM(context, -1.0f, 1.0f);
//    } else if(axis == MVImageFlipXAxisAndYAxis){
//        // just flip Y
//        CGContextTranslateCTM(context, self.size.width, 0);
//        CGContextScaleCTM(context, -1.0f, 1.0f);
//    }

    CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), img.CGImage);

    UIImage *flipedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return flipedImage;
}

-(void)caseAAA_0{
    //the triangle wrote by myself.
    if(inited){}else{
        float scale = [[UIScreen mainScreen] scale];
        CGRect bounds = [[UIScreen mainScreen] bounds];
        bounds.origin.x = 0;
        bounds.origin.y = 0;
        bounds.size.width *=scale;
        bounds.size.height *=scale;
        NSLog(@"view scale:%f rect:%f,%f %f,%f",scale,bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
        
        //            int x=0,y=0,width=480, height=800;
        int x=bounds.origin.x,y=bounds.origin.y,width=bounds.size.width, height=bounds.size.height;
        glViewport(x, y, width, height);
        
        
        glGenBuffers(1, &VBO);
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        const char *vertexShaderSource =
        //    "#version 330 core\n"
        //    "#version 300 core\n"
        "#version 300 es\n"
        "layout (location = 0) in vec3 aPos;\n"
        "void main()\n"
        "{\n"
        "   gl_Position =vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
        "}\0";
        unsigned int vertexShader;
        vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
        glCompileShader(vertexShader);
        int  success;
        char infoLog[512];
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
        if(!success)
        {
            glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
            NSLog(@"ERROR::SHADER::VERTEX::COMPILATION_FAILED:%s",infoLog);
        }
        /* GLSL ES 3.0 removes the gl_FragData and gl_FragColor builtin fragment output variables.
         Instead, you declare your own fragment output variables with the out qualifier.
         */
        const char *fragmentShaderSource=
        //    "#version 330 core\n"
        //    "#version 300 core\n\n"
        "#version 300 es\n\n"
        "out mediump vec4 FragColor;\n"
        "void main()\n"
        "{\n"
        "    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
        "}";
        unsigned int fragmentShader;
        fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
        glCompileShader(fragmentShader);
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
        if(!success)
        {
            glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
            NSLog(@"ERROR::SHADER::fragment::COMPILATION_FAILED:%s",infoLog);
        }
        shaderProgram = glCreateProgram();
        
        glAttachShader(shaderProgram, vertexShader);
        glAttachShader(shaderProgram, fragmentShader);
        glLinkProgram(shaderProgram);
        
        
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
        if(!success) {
            glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
            NSLog(@"ERROR::SHADER::link::%s",infoLog);
        }
        glUseProgram(shaderProgram);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        
        //layout is 0 in the vertex shader
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        glEnableVertexAttribArray(0);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        
        
        // ..:: Initialization code (done once (unless your object frequently changes)) :: ..
        // 1. bind Vertex Array Object
        glBindVertexArray(VAO);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        // 2. copy our vertices array in a buffer for OpenGL to use
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        // 3. then set our vertex attributes pointers
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        glEnableVertexAttribArray(0);
        //    CHECK_GL_ERROR();
        { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
        inited=YES;
    }
    // ..:: Drawing code (in render loop) :: ..
    // 4. draw the object
    glUseProgram(shaderProgram);
    //    CHECK_GL_ERROR();
    { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
    glBindVertexArray(VAO);
    //    CHECK_GL_ERROR();
    { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
    glDrawArrays(GL_TRIANGLES, 0, 3);
    //    CHECK_GL_ERROR();
    { GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error,  __FUNCTION__, __LINE__); }
    [self swapBuffers];
    
}
-(void)caseAAA {
    //the trianble. copied from. case AAA
    //https://learnopengl.com/code_viewer_gh.php?code=src/1.getting_started/2.1.hello_triangle/hello_triangle.cpp
    if(inited){
        //            return; //the triagle is always there, does not disapper.
    }else{
        float scale = [[UIScreen mainScreen] scale];
        CGRect bounds = [[UIScreen mainScreen] bounds];
        bounds.origin.x = 0;
        bounds.origin.y = 0;
        bounds.size.width *=scale;
        bounds.size.height *=scale;
        NSLog(@"view scale:%f rect:%f,%f %f,%f",scale,bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
        
        //            int x=0,y=0,width=480, height=800;
        int x=bounds.origin.x,y=bounds.origin.y,width=bounds.size.width, height=bounds.size.height;
        glViewport(x, y, width, height);
        
        
        const char *vertexShaderSource = "#version 300 es\n\n" //"#version 330 core\n"
        "layout (location = 0) in vec3 aPos;\n"
        "void main()\n"
        "{\n"
        "   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
        "}\0";
        const char *fragmentShaderSource = "#version 300 es\n\n" //"#version 330 core\n"
        //            "precision highp float;\n"
        //            "out vec4 FragColor;\n" //ERROR::SHADER::FRAGMENT::COMPILATION_FAILED:ERROR: 0:3: 'vec4' : declaration must include a precision qualifier for type
        //            "out vec4f FragColor;\n" //ERROR::SHADER::FRAGMENT::COMPILATION_FAILED:ERROR: 0:3: 'FragColor' : syntax error: syntax error
        //            "out vec4f FragColor;\n" //?
        "out mediump vec4 FragColor;\n"
        "void main()\n"
        "{\n"
        "   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
        "}\n\0";
        
        // build and compile our shader program
        // ------------------------------------
        // vertex shader
        unsigned int vertexShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
        glCompileShader(vertexShader);
        // check for shader compile errors
        int success;
        char infoLog[512];
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
            NSLog(@"ERROR::SHADER::VERTEX::COMPILATION_FAILED:%s",infoLog);
            return;
        }
        // fragment shader
        unsigned int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
        glCompileShader(fragmentShader);
        // check for shader compile errors
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
            NSLog(@"ERROR::SHADER::FRAGMENT::COMPILATION_FAILED:%s",infoLog);
            return;
        }
        // link shaders
        //unsigned int
        shaderProgram = glCreateProgram();
        glAttachShader(shaderProgram, vertexShader);
        glAttachShader(shaderProgram, fragmentShader);
        glLinkProgram(shaderProgram);
        // check for linking errors
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
        if (!success) {
            glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
            NSLog(@"ERROR::SHADER::PROGRAM::LINKING_FAILED:%s",infoLog);
            return;
        }
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        
        // set up vertex data (and buffer(s)) and configure vertex attributes
        // ------------------------------------------------------------------
        float vertices[] = {
            -0.5f, -0.5f, 0.0f, // left
            0.5f, -0.5f, 0.0f, // right
            0.0f,  0.5f, 0.0f  // top
        };
        
        //            unsigned int VBO, VAO;
        glGenVertexArrays(1, &VAO);
        glGenBuffers(1, &VBO);
        // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
        glBindVertexArray(VAO);
        
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(0);
        
        // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
        // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
        glBindVertexArray(0);
        inited=YES;
        
        // uncomment this call to draw in wireframe polygons.
        //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    }
    // render loop
    // -----------
    //            while (YES)
    {
        // input
        // -----
        //                processInput(window);
        
        // render
        // ------
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // draw our first triangle
        glUseProgram(shaderProgram);
        glBindVertexArray(VAO); // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
        glDrawArrays(GL_TRIANGLES, 0, 3);
        // glBindVertexArray(0); // no need to unbind it every time
        
        // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
        // -------------------------------------------------------------------------------
        [self swapBuffers];
        //                glfwSwapBuffers(window);
        //                glfwPollEvents();
    }
    
}
@end
