package com.castlelecs.rec.android

import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.os.Bundle
import androidx.activity.ComponentActivity
import com.castlelecs.rec.android.domain.Renderer
import com.castlelecs.rec.android.domain.RendererImpl
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import com.google.ar.core.ArCoreApk
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class MainActivity : ComponentActivity(), GLSurfaceView.Renderer {

    private lateinit var surfaceView: GLSurfaceView
    private val backgroundRenderer: Renderer = RendererImpl()
    private var session: Session? = null

    private var installRequested = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_main)

        surfaceView = findViewById(R.id.surfaceview)
        // TODO: Set display rotation helper here

        surfaceView.preserveEGLContextOnPause = true
        surfaceView.setEGLContextClientVersion(2)
        surfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0)
        surfaceView.setRenderer(this)
        surfaceView.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
        surfaceView.setWillNotDraw(false)
    }

    override fun onResume() {
        super.onResume()

        if (session == null) {
            try {
                when (ArCoreApk.getInstance().requestInstall(this, !installRequested)) {
                    ArCoreApk.InstallStatus.INSTALL_REQUESTED -> installRequested = true
                    else -> {}
                }

                // TODO: Not enough permissions (every possible case should be covered)
                if (CameraPermissionHelper.hasCameraPermission(this)) {
                    CameraPermissionHelper.requestCameraPermission(this)
                    return
                }

                session = Session(this)
            } catch (e: Exception) {
                println(e)
                return
            }
        }

        try {
            session?.resume()
            surfaceView.onResume()
            // TODO: displayRotationHelper.onResume()
        } catch (e: Exception) {
            println(e)
        }
    }

    override fun onPause() {
        super.onPause()

        session?.let { s ->
            /* displayRotationHelper.onPause() */
            surfaceView.onPause()
            s.pause()
        }
    }

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0.1f, 0.1f, 0.1f, 1f)

        try {
            backgroundRenderer.createOnGlThread(context = this)
        } catch (e: Exception) {
            println(e)
        }
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        // TODO: displayRotationHelper.onSurfaceChanged(width, height)
        GLES20.glViewport(0, 0, width, height);
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)

        // TODO: displayRotationHelper.updateSessionIfNeeded(session)

        session?.let { s ->
            s.setCameraTextureName(backgroundRenderer.getTextureId())

            val frame = s.update()

            backgroundRenderer.draw(frame)
        }
    }
}
