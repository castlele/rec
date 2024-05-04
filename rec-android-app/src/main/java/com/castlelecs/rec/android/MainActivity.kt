package com.castlelecs.rec.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.google.ar.core.Frame
import io.github.sceneview.animation.Transition.animateRotation
import io.github.sceneview.ar.ARScene
import io.github.sceneview.ar.rememberARCameraNode
import io.github.sceneview.math.Rotation
import io.github.sceneview.rememberEngine
import io.github.sceneview.rememberModelLoader
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            Box(modifier = Modifier.fillMaxSize()) {
                val engine = rememberEngine()
                val modelLoader = rememberModelLoader(engine)
                val cameraNode = rememberARCameraNode(engine)
                var frame by remember { mutableStateOf<Frame?>(null) }
                val cameraTransition = rememberInfiniteTransition(label = "CameraTransition")
                val cameraRotation by cameraTransition.animateRotation(
                    initialValue = Rotation(y = 0.0f),
                    targetValue = Rotation(y = 360.0f),
                    animationSpec = infiniteRepeatable(
                        animation = tween(durationMillis = 7.seconds.toInt(DurationUnit.MILLISECONDS))
                    )
                )

                ARScene(
                    modifier = Modifier.fillMaxSize(),
                    engine = engine,
                    cameraNode = cameraNode,
                    modelLoader = modelLoader,
                    onSessionUpdated = { _, updatedFrame ->
                        frame = updatedFrame
                    },
                    onViewUpdated = {
                        cameraNode.rotation = cameraRotation
                    }
                )
            }
        }
    }
}
