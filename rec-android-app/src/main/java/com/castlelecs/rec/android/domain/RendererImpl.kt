package com.castlelecs.rec.android.domain

import android.content.Context
import android.opengl.GLES20
import android.opengl.GLES11Ext
import com.google.ar.core.Frame
import com.google.ar.core.Coordinates2d
import java.nio.FloatBuffer
import java.nio.ByteBuffer;
import java.nio.ByteOrder

class RendererImpl : Renderer {

    private val quadCoords: FloatBuffer
        get() {
            val bbCoords = ByteBuffer.allocate(QUAD_COORDS.size * FLOAT_SIZE)

            bbCoords.order(ByteOrder.nativeOrder())

            val fb = bbCoords.asFloatBuffer()

            fb.put(QUAD_COORDS)
            fb.position(0)

            return fb
        }
    private val quadTexCoords: FloatBuffer
        get() {
            val bbTexCoordsTransformed = ByteBuffer.allocateDirect(
                NUM_VERTICES * TEXCOORDS_PER_VERTEX * FLOAT_SIZE
            )

            bbTexCoordsTransformed.order(ByteOrder.nativeOrder())

            return bbTexCoordsTransformed.asFloatBuffer()
        }

    private var quadProgram = 0
    private var quadPositionParam = 0
    private var quadTexCoordParam = 0
    private var textureId = -1

    override fun getTextureId(): Int {
        return textureId
    }

    override fun createOnGlThread(context: Context) {
        val textures = IntArray(1)

        GLES20.glGenTextures(1, textures, 0)

        textureId = textures[0]

        val textureTarget = GLES11Ext.GL_TEXTURE_EXTERNAL_OES

        GLES20.glBindTexture(textureTarget, textureId)
        GLES20.glTexParameteri(textureTarget, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(textureTarget, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(textureTarget, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(textureTarget, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)

        if (NUM_VERTICES != QUAD_COORDS.size / COORDS_PER_VERTEX) {
            throw RuntimeException("Unexpected number of vertices in BackgroundRenderer.")
        }

        val vertexShader = ShaderUtil.loadGLShader(
            type = GLES20.GL_VERTEX_SHADER,
            shaderCode = """
            attribute vec4 a_Position;
attribute vec2 a_TexCoord;

varying vec2 v_TexCoord;

void main() {
    gl_Position = a_Position;
    v_TexCoord = a_TexCoord;
}
            """,
        )
        val fragmentShader = ShaderUtil.loadGLShader(
            type = GLES20.GL_FRAGMENT_SHADER,
            shaderCode = """
#extension GL_OES_EGL_image_external : require

precision mediump float;
varying vec2 v_TexCoord;
uniform samplerExternalOES sTexture;

void main() {
    gl_FragColor = texture2D(sTexture, v_TexCoord);
}

            """,
        )

        // val vertexShader = ShaderUtil.loadGLShader(
        //     context = context,
        //     type = GLES20.GL_VERTEX_SHADER,
        //     fileName = CAMERA_VERTEX_SHADER_NAME,
        // )
        // val fragmentShader = ShaderUtil.loadGLShader(
        //     context = context,
        //     type = GLES20.GL_FRAGMENT_SHADER,
        //     fileName = CAMERA_FRAGMENT_SHADER_NAME,
        // )

        quadProgram = GLES20.glCreateProgram()

        GLES20.glAttachShader(quadProgram, vertexShader)
        GLES20.glAttachShader(quadProgram, fragmentShader)
        GLES20.glLinkProgram(quadProgram)
        GLES20.glUseProgram(quadProgram)

        quadPositionParam = GLES20.glGetAttribLocation(quadProgram, "a_Position")
        quadTexCoordParam = GLES20.glGetAttribLocation(quadProgram, "a_Position")
    }

    override fun draw(frame: Frame) {
        if (frame.hasDisplayGeometryChanged()) {
            frame.transformCoordinates2d(
                Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES,
                quadCoords,
                Coordinates2d.TEXTURE_NORMALIZED,
                quadTexCoords
            )
        }

        if (frame.timestamp == 0L) {
            return
        }

        draw()
    }

    private fun draw() {
        quadTexCoords.position(0)

        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(false)

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId)

        GLES20.glUseProgram(quadProgram)

        GLES20.glVertexAttribPointer(
            quadPositionParam,
            COORDS_PER_VERTEX,
            GLES20.GL_FLOAT,
            false,
            0,
            quadCoords,
        )
        GLES20.glVertexAttribPointer(
            quadTexCoordParam,
            TEXCOORDS_PER_VERTEX,
            GLES20.GL_FLOAT,
            false,
            0,
            quadTexCoords,
        )

        GLES20.glEnableVertexAttribArray(quadPositionParam)
        GLES20.glEnableVertexAttribArray(quadTexCoordParam)

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        GLES20.glDisableVertexAttribArray(quadPositionParam)
        GLES20.glDisableVertexAttribArray(quadTexCoordParam)

        GLES20.glDepthMask(true)
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)

    }

    companion object {
        private const val CAMERA_VERTEX_SHADER_NAME = "shaders/screenquad.vert"
        private const val CAMERA_FRAGMENT_SHADER_NAME = "shaders/screenquad.frag"

        private const val NUM_VERTICES = 4
        private const val COORDS_PER_VERTEX = 2
        private const val TEXCOORDS_PER_VERTEX = 2
        private const val FLOAT_SIZE = 4

        private val QUAD_COORDS = floatArrayOf(-1.0f, -1.0f, +1.0f, -1.0f, -1.0f, +1.0f, +1.0f, +1.0f)
    }
}
