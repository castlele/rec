package com.castlelecs.rec.android.domain

import android.content.Context
import com.google.ar.core.Frame

interface Renderer {
    fun getTextureId(): Int

    fun createOnGlThread(context: Context)
    fun draw(frame: Frame)
}
