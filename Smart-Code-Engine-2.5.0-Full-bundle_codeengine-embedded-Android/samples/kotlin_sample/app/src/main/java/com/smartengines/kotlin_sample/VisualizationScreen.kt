/*
  Copyright (c) 2016-2024, Smart Engines Service LLC
  All rights reserved.
*/

package com.smartengines.kotlin_sample

import android.util.Size
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.smartengines.core.engine.Quad
import com.smartengines.core.engine.QuadFrame
import com.smartengines.core.engine.QuadPoint
import com.smartengines.core.engine.Visualization

// SETTINGS
private const val PRIMARY_LINE_DP       =  3
private const val SECONDARY_LINE_DP     =  2
private val PRIMARY_COLOR               = Color.Green
private val SECONDARY_COLOR             = Color.Red
private val INSTRUCTION_COLOR           = Color.Yellow


@Composable
fun VisualizationScreen(visualization: Visualization){
    val density = LocalDensity.current

    // QUADS PRIMARY
    visualization.quadsPrimary?.let {
        val quadsPrimary by it.collectAsState(null)
        quadsPrimary?.let {
            it.lastOrNull()?.let {
                QuadFrameScreen(
                    quadFrame = it,
                    lineColor = PRIMARY_COLOR,
                    lineWidth = density.run { PRIMARY_LINE_DP.dp.toPx() }
                )
            }
        }
    }

    // QUADS SECONDARY
    visualization.quadsSecondary?.let {
        val quadsPrimary by it.collectAsState(null)
        quadsPrimary?.let {
            it.lastOrNull()?.let {
                QuadFrameScreen(
                    quadFrame = it,
                    lineColor = SECONDARY_COLOR,
                    lineWidth = density.run { SECONDARY_LINE_DP.dp.toPx() }
                )
            }
        }
    }

    // INSTRUCTION
    visualization.instruction?.let {
        val instruction by it.collectAsState(initial = null)
        instruction?.let {
            InstructionScreen(it)
        }
    }
}

@Composable
fun QuadFrameScreen(quadFrame: QuadFrame, lineColor:Color, lineWidth:Float){
    Canvas(modifier = Modifier.fillMaxSize()){
        quadFrame.quads.forEach {
            drawQuad(it, quadFrame.imageSize, lineColor, lineWidth, this)
        }
    }

}

/**
 *  The main drawing function
 *
 *   @param field Dimensions of the rectangle to draw
 */
fun drawQuad(quad: Quad?, field: Size, color: Color, lineWidth:Float, scope: DrawScope){
    scope.apply {
        // SCALE FRAME BUT NOT THE LINE WIDTH !!!
        val sx = size.width/field.width
        val sy = size.height/field.height
        val s = Math.min(sx,sy) // изображение втиснуто в экран с сохранением пропорций
        val dx = (size.width  - s*field.width)/2
        val dy = (size.height - s*field.height)/2
        translate(left = dx, top = dy) {
            quad?.points?.let { points ->
                if (points.size > 1) {
                    for (i in 1 until points.size) {
                        drawLine(
                            color,
                            points[i - 1].offset(s),
                            points[i].offset(s),
                            lineWidth
                        )
                    }
                    drawLine(
                        color,
                        points.first().offset(s),
                        points.last().offset(s),
                        lineWidth
                    )
                }
            }
        }
    }
}
private fun QuadPoint.offset(scale:Float): Offset = Offset(x*scale,y*scale)

@Composable
fun InstructionScreen(instruction:String){
    Text(
        modifier = Modifier.fillMaxWidth().padding(top = 10.dp),
        textAlign = TextAlign.Center,
        text = instruction,
        style = MaterialTheme.typography.headlineMedium,
        color = INSTRUCTION_COLOR)
}

//--------------------------------------------------------------------------------------------------
// PREVIEW
@Preview(showBackground = false, showSystemUi = false)
@Composable
fun Visualization_Preview() {
    val primary = QuadFrame(
        quads = setOf(
            Quad(points = listOf(
                QuadPoint(10f,10f),
                QuadPoint(90f,10f),
                QuadPoint(90f,90f),
                QuadPoint(10f,90f),
            ))
        ),
        imageSize = Size(100,100)
    )
    val secondary = QuadFrame(
        quads = setOf(
            Quad(points = listOf(
                QuadPoint(20f,20f),
                QuadPoint(40f,20f),
                QuadPoint(40f,40f),
                QuadPoint(20f,40f),
            )),
            Quad(points = listOf(
                QuadPoint(50f,50f),
                QuadPoint(80f,50f),
                QuadPoint(80f,80f),
                QuadPoint(50f,80f),
            ))
        ),
        imageSize = Size(100,100)
    )
    val density = LocalDensity.current

    QuadFrameScreen(
        quadFrame = primary,
        lineColor = PRIMARY_COLOR,
        lineWidth = density.run { PRIMARY_LINE_DP.dp.toPx() }
    )
    QuadFrameScreen(
        quadFrame = secondary,
        lineColor = SECONDARY_COLOR,
        lineWidth = density.run { SECONDARY_LINE_DP.dp.toPx() }
    )
    InstructionScreen(instruction = "The instruction")


}
