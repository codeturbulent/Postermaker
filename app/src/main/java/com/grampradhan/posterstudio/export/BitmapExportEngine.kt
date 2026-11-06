package com.grampradhan.posterstudio.export

import android.app.ActivityManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Rect
import android.graphics.RectF
import android.net.Uri
import android.util.Log
import android.view.View
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.core.content.FileProvider
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.savedstate.SavedStateRegistry
import androidx.savedstate.SavedStateRegistryController
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.grampradhan.posterstudio.ui.editor.EditorLayer
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import kotlin.coroutines.coroutineContext
import kotlin.math.max
import kotlin.math.min

import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Production-ready export engine handling off-screen Compose tree rendering,
 * high-DPI flex banner print rendering, RAM-aware resolution capping, and compression.
 */
@Singleton
class BitmapExportEngine @Inject constructor(
    @ApplicationContext private val context: Context
) {

    companion object {
        private const val TAG = "BitmapExportEngine"
        private const val SIX_GB_BYTES = 6L * 1024L * 1024L * 1024L
        private const val MAX_CAPPED_DIMENSION = 6000
    }

    data class ExportResult(
        val file: File,
        val contentUri: Uri,
        val width: Int,
        val height: Int,
        val sizeBytes: Long
    )

    /**
     * Off-screen renders a Compose UI tree at target pixel dimensions.
     */
    suspend fun exportFromCompose(
        content: @Composable () -> Unit,
        widthPx: Int,
        heightPx: Int
    ): Bitmap = withContext(Dispatchers.Main) {
        val (safeWidth, safeHeight) = sanitizeDimensions(widthPx, heightPx)

        val composeView = ComposeView(context).apply {
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindowOrReleasedFromPool)
            setContent(content)
        }

        val emptyOwner = object : LifecycleOwner, ViewModelStoreOwner, SavedStateRegistryOwner {
            private val lifecycleRegistry = LifecycleRegistry(this).apply {
                currentState = Lifecycle.State.RESUMED
            }
            private val savedStateRegistryController = SavedStateRegistryController.create(this).apply {
                performRestore(null)
            }
            private val store = ViewModelStore()

            override val lifecycle: Lifecycle get() = lifecycleRegistry
            override val viewModelStore: ViewModelStore get() = store
            override val savedStateRegistry: SavedStateRegistry get() = savedStateRegistryController.savedStateRegistry
        }

        composeView.setViewTreeLifecycleOwner(emptyOwner)
        composeView.setViewTreeViewModelStoreOwner(emptyOwner)
        composeView.setViewTreeSavedStateRegistryOwner(emptyOwner)

        val widthSpec = View.MeasureSpec.makeMeasureSpec(safeWidth, View.MeasureSpec.EXACTLY)
        val heightSpec = View.MeasureSpec.makeMeasureSpec(safeHeight, View.MeasureSpec.EXACTLY)
        composeView.measure(widthSpec, heightSpec)
        composeView.layout(0, 0, safeWidth, safeHeight)

        val bitmap = Bitmap.createBitmap(safeWidth, safeHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        composeView.draw(canvas)

        bitmap
    }

    /**
     * Canvas-based rendering optimized for high-resolution flex banners and prints.
     */
    suspend fun exportFromLayerModel(
        layers: List<EditorLayer>,
        widthPx: Int,
        heightPx: Int,
        referenceCanvasWidth: Float = 1080f,
        referenceCanvasHeight: Float = 1080f
    ): Bitmap = withContext(Dispatchers.Default) {
        coroutineContext.ensureActive()

        val (targetWidth, targetHeight) = sanitizeDimensions(widthPx, heightPx)
        val outputBitmap = Bitmap.createBitmap(targetWidth, targetHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(outputBitmap)

        val scaleX = targetWidth.toFloat() / referenceCanvasWidth
        val scaleY = targetHeight.toFloat() / referenceCanvasHeight
        val globalScale = min(scaleX, scaleY)

        val sortedLayers = layers.sortedBy { it.zIndex }

        for (layer in sortedLayers) {
            coroutineContext.ensureActive()
            canvas.save()

            // Apply transformed position scaled to destination canvas
            canvas.translate(layer.translationX * scaleX, layer.translationY * scaleY)
            canvas.rotate(layer.rotation)
            canvas.scale(layer.scale, layer.scale)

            when (layer) {
                is EditorLayer.BackgroundLayer -> {
                    val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
                    if (layer.bitmap != null) {
                        val destRect = Rect(0, 0, targetWidth, targetHeight)
                        canvas.drawBitmap(layer.bitmap, null, destRect, paint)
                    } else {
                        canvas.drawColor(layer.color)
                    }
                }
                is EditorLayer.ImageLayer -> {
                    val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
                    val bmp = layer.bitmap ?: layer.imagePath?.let { BitmapFactory.decodeFile(it) }
                    if (bmp != null) {
                        canvas.drawBitmap(bmp, 0f, 0f, paint)
                    }
                }
                is EditorLayer.StickerLayer -> {
                    val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
                    layer.bitmap?.let { canvas.drawBitmap(it, 0f, 0f, paint) }
                }
                is EditorLayer.TextLayer -> {
                    renderTextLayer(canvas, layer, globalScale)
                }
            }
            canvas.restore()
        }

        outputBitmap
    }

    private fun renderTextLayer(canvas: Canvas, layer: EditorLayer.TextLayer, globalScale: Float) {
        val effectiveTextSize = layer.fontSizeSp * globalScale * 1.5f

        // Draw drop shadow if enabled
        if (layer.hasShadow) {
            val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(160, 0, 0, 0)
                textSize = effectiveTextSize
                textAlign = Paint.Align.CENTER
                typeface = layer.typeface ?: Typeface.DEFAULT_BOLD
            }
            drawTextInternal(canvas, layer.text, 4f * globalScale, 4f * globalScale, shadowPaint, layer.curvedArc)
        }

        // Draw stroke if configured
        if (layer.strokeWidthDp > 0f) {
            val strokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = layer.strokeColor
                style = Paint.Style.STROKE
                strokeWidth = layer.strokeWidthDp * globalScale * 2f
                textSize = effectiveTextSize
                textAlign = Paint.Align.CENTER
                strokeJoin = Paint.Join.ROUND
                strokeCap = Paint.Cap.ROUND
                typeface = layer.typeface ?: Typeface.DEFAULT_BOLD
            }
            drawTextInternal(canvas, layer.text, 0f, 0f, strokePaint, layer.curvedArc)
        }

        // Draw fill text
        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = layer.textColor
            style = Paint.Style.FILL
            textSize = effectiveTextSize
            textAlign = Paint.Align.CENTER
            typeface = layer.typeface ?: Typeface.DEFAULT_BOLD
        }
        drawTextInternal(canvas, layer.text, 0f, 0f, textPaint, layer.curvedArc)
    }

    private fun drawTextInternal(
        canvas: Canvas,
        text: String,
        dx: Float,
        dy: Float,
        paint: Paint,
        arcDegrees: Float
    ) {
        if (arcDegrees != 0f) {
            val path = Path()
            val radius = 400f
            val oval = RectF(-radius + dx, -radius + dy, radius + dx, radius + dy)
            val sweep = arcDegrees.coerceIn(-180f, 180f)
            val startAngle = 270f - (sweep / 2f)
            path.addArc(oval, startAngle, sweep)
            canvas.drawTextOnPath(text, path, 0f, 0f, paint)
        } else {
            canvas.drawText(text, dx, dy, paint)
        }
    }

    /**
     * Calculates 300 DPI target pixels and caps long edge to 6000px if device has < 6 GB RAM.
     */
    fun sanitizeDimensions(widthPx: Int, heightPx: Int): Pair<Int, Int> {
        val totalRam = getTotalDeviceRam()
        val longEdge = max(widthPx, heightPx)

        if (totalRam < SIX_GB_BYTES && longEdge > MAX_CAPPED_DIMENSION) {
            val ratio = MAX_CAPPED_DIMENSION.toFloat() / longEdge
            val cappedWidth = (widthPx * ratio).toInt()
            val cappedHeight = (heightPx * ratio).toInt()
            Log.w(
                TAG,
                "Device RAM is ${totalRam / (1024 * 1024)} MB (< 6 GB). " +
                        "Capping flex banner export from ${widthPx}x${heightPx} to ${cappedWidth}x${cappedHeight} to prevent OOM."
            )
            return Pair(cappedWidth, cappedHeight)
        }
        return Pair(widthPx, heightPx)
    }

    /**
     * Calculates target pixel dimensions from physical print inches at 300 DPI.
     */
    fun calculatePrintPixels(widthInches: Float, heightInches: Float, dpi: Int = 300): Pair<Int, Int> {
        val w = (widthInches * dpi).toInt()
        val h = (heightInches * dpi).toInt()
        return sanitizeDimensions(w, h)
    }

    /**
     * Saves bitmap to disk with FileProvider URI.
     */
    suspend fun saveAndPrepareShare(
        bitmap: Bitmap,
        isLosslessPng: Boolean = false,
        addWatermark: Boolean = false
    ): ExportResult = withContext(Dispatchers.IO) {
        val processedBitmap = if (addWatermark) addWatermarkToBitmap(bitmap) else bitmap

        val postersDir = File(context.cacheDir, "posters").apply { if (!exists()) mkdirs() }
        val extension = if (isLosslessPng) "png" else "jpg"
        val fileName = "GP_${System.currentTimeMillis()}.$extension"
        val outputFile = File(postersDir, fileName)

        val bytes = if (isLosslessPng) {
            BitmapCompressor.compressForPrint(processedBitmap)
        } else {
            BitmapCompressor.compressForWhatsApp(processedBitmap)
        }

        FileOutputStream(outputFile).use { it.write(bytes) }

        val contentUri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            outputFile
        )

        ExportResult(
            file = outputFile,
            contentUri = contentUri,
            width = processedBitmap.width,
            height = processedBitmap.height,
            sizeBytes = outputFile.length()
        )
    }

    private fun addWatermarkToBitmap(src: Bitmap): Bitmap {
        val result = src.copy(Bitmap.Config.ARGB_8888, true)
        val canvas = Canvas(result)
        val text = "GramPradhan Poster Studio"
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(120, 255, 255, 255)
            textSize = (result.width * 0.025f).coerceIn(24f, 72f)
            style = Paint.Style.FILL
            textAlign = Paint.Align.RIGHT
        }
        val x = result.width - 24f
        val y = result.height - 24f
        canvas.drawText(text, x, y, paint)
        return result
    }

    private fun getTotalDeviceRam(): Long {
        return try {
            val actManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val memInfo = ActivityManager.MemoryInfo()
            actManager.getMemoryInfo(memInfo)
            memInfo.totalMem
        } catch (e: Exception) {
            3L * 1024L * 1024L * 1024L // Safe 3GB fallback
        }
    }

    /**
     * High-efficiency image compressor supporting WhatsApp size limits and lossless flex prints.
     */
    object BitmapCompressor {

        /**
         * Iteratively reduces JPEG quality to ensure payload fits WhatsApp sharing (target <= 2MB).
         */
        fun compressForWhatsApp(bitmap: Bitmap, targetMaxBytes: Long = 2L * 1024L * 1024L): ByteArray {
            var quality = 95
            var stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)

            while (stream.size() > targetMaxBytes && quality > 40) {
                stream.reset()
                quality -= 10
                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)
            }
            return stream.toByteArray()
        }

        /**
         * Lossless PNG compression for print-ready flex banners.
         */
        fun compressForPrint(bitmap: Bitmap): ByteArray {
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            return stream.toByteArray()
        }
    }
}
