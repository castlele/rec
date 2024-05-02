package com.castlelecs.rec.android.domain

import android.content.Context
import android.opengl.GLES20
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.IOException

object ShaderUtil {

    fun loadGLShader(type: Int, shaderCode: String): Int {
        val shader = GLES20.glCreateShader(type)

        GLES20.glShaderSource(shader, shaderCode)
        GLES20.glCompileShader(shader)

        return shader
    }

    fun loadGLShader(
        context: Context,
        type: Int,
        fileName: String
    ): Int {
        val code = readShaderFileFromAssets(context, fileName)
        var shader = GLES20.glCreateShader(type)

        GLES20.glShaderSource(shader, code)
        GLES20.glCompileShader(shader)

        var compileStatus = intArrayOf()
        GLES20.glGetShaderiv(shader, GLES20.GL_COMPILE_STATUS, compileStatus, 0)

        if (compileStatus[0] == 0) {
            print("Error compiling shader: ${GLES20.glGetShaderInfoLog(shader)}")
            GLES20.glDeleteShader(shader)
            shader = 0
        }

        if (shader == 0) {
            throw RuntimeException("Error creating shader")
        }

        return shader
    }

    private fun readShaderFileFromAssets(
        context: Context,
        fileName: String
    ): String {
        val reader = context
            .assets
            .open(fileName)
            .let {
                BufferedReader(InputStreamReader(it))
            }

        val builder = StringBuilder()

        with(builder) {
            var line = reader.readLine()

            while (line != null) {
                val tokens = line.split(" ", limit = 1)

                if (tokens[0] == "#include") {
                    var includeFileName = tokens[1]

                    includeFileName = includeFileName.replace("\"", "")

                    if (includeFileName == fileName) {
                        throw IOException("Do not include the calling file.")
                    }

                    append(readShaderFileFromAssets(context, includeFileName))
                } else {
                    append(line).append("\n")
                }

                line = reader.readLine()
            }
        }

        return builder.toString()
    }
}
