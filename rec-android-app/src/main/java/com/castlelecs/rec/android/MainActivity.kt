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
import androidx.compose.ui.graphics.Color
import com.google.ar.core.Config
import com.google.ar.core.Frame
import com.google.ar.core.Plane
import io.github.sceneview.animation.Transition.animateRotation
import io.github.sceneview.ar.ARScene
import io.github.sceneview.ar.arcore.createAnchorOrNull
import io.github.sceneview.ar.arcore.isValid
import io.github.sceneview.ar.node.AnchorNode
import io.github.sceneview.ar.rememberARCameraNode
import io.github.sceneview.math.Position
import io.github.sceneview.math.Rotation
import io.github.sceneview.math.Size
import io.github.sceneview.model.ModelInstance
import io.github.sceneview.node.CubeNode
import io.github.sceneview.node.ModelNode
import io.github.sceneview.rememberCollisionSystem
import io.github.sceneview.rememberEngine
import io.github.sceneview.rememberModelLoader
import io.github.sceneview.rememberNodes
import io.github.sceneview.rememberOnGestureListener
import io.github.sceneview.rememberView
import io.github.sceneview.rememberMaterialLoader
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit

private const val kModelFile = "models/damaged_helmet.glb"
private const val kMaxModelInstances = 10

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            MyApplicationTheme {
                Box(
                    modifier = Modifier.fillMaxSize()
                ) {
                    val engine = rememberEngine()
                    val modelLoader = rememberModelLoader(engine)
                    val materialLoader = rememberMaterialLoader(engine)
                    val modelInstances = remember { mutableListOf<ModelInstance>() }
                    val cameraNode = rememberARCameraNode(engine)
                    val childNodes = rememberNodes()
                    var frame by remember { mutableStateOf<Frame?>(null) }

                    ARScene(
                        modifier = Modifier.fillMaxSize(),
                        engine = engine,
                        cameraNode = cameraNode,
                        childNodes = childNodes,
                        modelLoader = modelLoader,
                        // sessionConfiguration = { session, config ->
                        //     config.depthMode =
                        //         when (session.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) {
                        //             true -> Config.DepthMode.AUTOMATIC
                        //             else -> Config.DepthMode.DISABLED
                        //         }
                        //     config.instantPlacementMode = Config.InstantPlacementMode.LOCAL_Y_UP
                        //     config.lightEstimationMode =
                        //         Config.LightEstimationMode.ENVIRONMENTAL_HDR
                        // },
                        planeRenderer = true,
                        onSessionUpdated = { _, updatedFrame ->
                            frame = updatedFrame
                        },
                        // onViewCreated = {
                        //     planeRenderer.isVisible = false
                        // },
                        onViewUpdated = {
                        },
                        onGestureListener = rememberOnGestureListener(
                            onSingleTapConfirmed = { motionEvent, _ ->
                                val hitTestResults = frame?.hitTest(motionEvent)

                                hitTestResults
                                    ?.firstOrNull {
                                        it.isValid(
                                            planeTypes = setOf(
                                                Plane.Type.HORIZONTAL_UPWARD_FACING
                                            ),
                                            // point = false,
                                            // depthPoint = false,
                                            // instantPlacementPoint = false,
                                        )
                                    }
                                    ?.createAnchorOrNull()
                                    ?.let { anchor ->
                                        val node = AnchorNode(
                                            engine = engine,
                                            anchor = anchor,
                                        )

                                        // val model = ModelNode(
                                        //     modelInstance = modelInstances.apply {
                                        //         if (isEmpty()) {
                                        //             this += modelLoader.createInstancedModel(kModelFile, kMaxModelInstances)
                                        //         }
                                        //     }.removeLast(),
                                        //     scaleToUnits = 0.2f,
                                        // ).apply {
                                        //     isEditable = true
                                        // }

                                        val cube = CubeNode(
                                            engine = engine,
                                            size = Size(0.2f),
                                            // center = model.center,
                                            materialInstance = materialLoader.createColorInstance(Color.White.copy(alpha = 0.5f)),
                                        ).apply { isEditable = true }

                                        // model.addChildNode(cube)
                                        node.addChildNode(cube)

                                        childNodes += node
                                    }
                            },
                        ),
                    )
                }
            }
        }
    }
}
