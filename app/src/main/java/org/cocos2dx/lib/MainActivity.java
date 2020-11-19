package org.cocos2dx.lib;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityCompat;

import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;

public class MainActivity extends Activity  //AppCompatActivity
 {

    static MainActivity one;
    private GLSurfaceView gLView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        one=this;

        if (false) {
            setContentView(R.layout.activity_main);
            Toolbar toolbar = findViewById(R.id.toolbar);
//            setSupportActionBar(toolbar);

            FloatingActionButton fab = findViewById(R.id.fab);
            fab.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {


                    if (false) {
                        Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();

                    } else {
                        checkExternalPermission();
                    }

                }
            });
        } else {
            // Create a GLSurfaceView instance and set it
            // as the ContentView for this Activity.
            if (true) {
                gLView = new MyGLSurfaceView(this);
            } else {
                Cocos2dxGLSurfaceView cv = new Cocos2dxGLSurfaceView(this);
                gLView = cv;
                Cocos2dxRenderer renderer = new Cocos2dxRenderer();
                cv.setCocos2dxRenderer(renderer);
            }
            setContentView(gLView);
        }
    }

    @Override
    public void onBackPressed() {
        checkExternalPermission();
    }

    private void checkExternalPermission() {
        Log.i(tag, "check Permision");
        Context context = this; // NativeAPI.appActivity;
//        int perm = context.checkCallingOrSelfPermission("android.permission." + permName.toString());
//        return perm == PackageManager.PERMISSION_GRANTED;
        String p = "android.permission.WRITE_EXTERNAL_STORAGE";
        int perm = context.checkCallingOrSelfPermission(p);
        if (perm == PackageManager.PERMISSION_GRANTED) {
            onExternalGranted(true);
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                perm = context.checkSelfPermission(p);
                if (perm == PackageManager.PERMISSION_GRANTED) {
                    onExternalGranted(true);
                } else {
                    perm = context.checkSelfPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE);
                    if (perm == PackageManager.PERMISSION_GRANTED) {
                        Log.i(tag, "Permision is granted");
                        //File write logic here
                        onExternalGranted(true);
                    } else {
                        Log.i(tag, "will request storage permision:" + this + " since " + perm);
                        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, RequestCodeUUID);
                    }
                }
            } else {
                onExternalGranted(false);
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        Log.i(tag, "permision result:" + requestCode);
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (false && requestCode == RequestCodeUUID) {
//            onRequestPermissionsResult(permissions, grantResults);
        } else {
////            Context context = getApplicationContext();
//            CharSequence text = "Permission requested, but the caller is not recognized:" + requestCode;
//            int duration = Toast.LENGTH_LONG;
//            Toast toast = Toast.makeText(this, text, duration);
//            toast.show();
            StringBuilder sb = new StringBuilder();
            sb.append("permission result:");
            for (int i = 0; i < permissions.length; i++) {
                sb.append("," + permissions[i]);
            }
            sb.append('\n');
            for (int i = 0; i < grantResults.length; i++) {
                sb.append("," + grantResults[i]);
            }
            Log.i(tag, sb.toString());
        }
    }

    static int RequestCodeUUID = 1;
    static String tag = "testO";

    private void onExternalGranted(boolean b) {
        Log.i(tag, "external permision granted:" + b);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
