package org.cocos2dx.lib;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.view.KeyEvent;
import android.view.View;

class MyGLSurfaceView extends GLSurfaceView {



    private final GLSurfaceView.Renderer //MyGLRenderer
            renderer;

    public MyGLSurfaceView(Context context){
        super(context);

        // Create an OpenGL ES 2.0 context
//        setEGLContextClientVersion(2); //this line can cause problem.
        if(false)
        renderer = new MyGLRenderer();
        else
        renderer =new DemoRenderer();

        // Set the Renderer for drawing on the GLSurfaceView
        setRenderer(renderer);

// Render the view only when there is a change in the drawing data
//        setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
//        setOnKeyListener(l0);

    }
//    OnUnhandledKeyEventListener_here l0=new OnUnhandledKeyEventListener_here();
//
//    static class OnUnhandledKeyEventListener_here implements OnUnhandledKeyEventListener{
//
//        @Override
//        public boolean onUnhandledKeyEvent(View v, KeyEvent event) {
//            return false;
//        }
//    }

}
