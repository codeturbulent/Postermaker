package com.grampradhan.posterstudio.ml

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import androidx.exifinterface.media.ExifInterface
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.segmentation.Segmentation
import com.google.mlkit.vision.segmentation.selfie.SelfieSegmenterOptions
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.withContext
import java.io.InputStream
import java.nio.ByteBuffer
import kotlin.coroutines.coroutineContext
import kotlin.math.max
import kotlin.math.min

/**
 * Production-ready on-device background remover powered by Google ML Kit Selfie Segmentation.
 * Applies edge feathering (anti-aliasing) to eliminate jagged contours and preserves native subject resolution.
 */
class MLKitBackgroundRemover {

    private val segmenterOptions = SelfieSegmenterOptions.Builder()
        .setDetectorMode(SelfieSegmenterOptions.SINGLE_IMAGE_MODE)
        .build()

    private val segmenter = Segmentation.getClient(segmenterOptions)

    /**
     * Removes the background from the provided bitmap on [Dispatchers.Default].
     *
     * @param bitmap Input candidate portrait.
     * @param confidenceThreshold Confidence cut-off (default 0.7f).
     * @return Transparent ARGB_8888 cutout preserving native resolution.
     */
    suspend fun removeBackground(
        bitmap: Bitmap,
        confidenceThreshold: Float = 0.7f
    ): Bitmap = withContext(Dispatchers.Default) {
        coroutineContext.ensureActive()

        try {
            executeSegmentation(bitmap, confidenceThreshold)
        } catch (e: OutOfMemoryError) {
            // Low-end memory recovery: Downscale input bitmap by 50% and retry once
            coroutineContext.ensureActive()
            val downscaledWidth = max(1, bitmap.width / 2)
            val downscaledHeight = max(1, bitmap.height / 2)
            val downscaledBitmap = Bitmap.createScaledBitmap(bitmap, downscaledWidth, downscaledHeight, true)
            executeSegmentation(downscaledBitmap, confidenceThreshold)
        }
    }

    private suspend fun executeSegmentation(
        inputBitmap: Bitmap,
        confidenceThreshold: Float
    ): Bitmap = withContext(Dispatchers.Default) {
        coroutineContext.ensureActive()

        // 1. Constrain ML input size (ML Kit operates optimally <= 1024px, preventing OOM on 2-3GB RAM)
        val maxMlDim = 1024
        val scale = min(1.0f, maxMlDim.toFloat() / max(inputBitmap.width, inputBitmap.height))
        val mlBitmap = if (scale < 1.0f) {
            Bitmap.createScaledBitmap(
                inputBitmap,
                (inputBitmap.width * scale).toInt(),
                (inputBitmap.height * scale).toInt(),
                true
            )
        } else {
            inputBitmap
        }

        coroutineContext.ensureActive()
        val image = InputImage.fromBitmap(mlBitmap, 0)

        // 2. Run synchronous detection off the main thread via Tasks.await
        val mask = Tasks.await(segmenter.process(image))
        coroutineContext.ensureActive()

        val maskWidth = mask.width
        val maskHeight = mask.height
        val maskBuffer: ByteBuffer = mask.buffer
        maskBuffer.rewind()

        // 3. Extract confidence values into an intermediate alpha bitmap
        val rawAlphaBitmap = Bitmap.createBitmap(maskWidth, maskHeight, Bitmap.Config.ARGB_8888)
        val pixels = IntArray(maskWidth * maskHeight)

        for (i in 0 until (maskWidth * maskHeight)) {
            val confidence = maskBuffer.float
            val alpha = if (confidence >= confidenceThreshold) {
                // Smooth transition near threshold boundary
                val ramp = ((confidence - confidenceThreshold) / (1f - confidenceThreshold)).coerceIn(0f, 1f)
                (ramp * 255).toInt()
            } else {
                0
            }
            // Pack into ARGB pixel with pure white RGB and computed alpha
            pixels[i] = (alpha shl 24) or 0x00FFFFFF
        }
        rawAlphaBitmap.setPixels(pixels, 0, maskWidth, 0, 0, maskWidth, maskHeight)

        coroutineContext.ensureActive()

        // 4. Upscale alpha mask to native subject resolution with bilinear filtering
        val nativeWidth = inputBitmap.width
        val nativeHeight = inputBitmap.height
        val scaledMask = Bitmap.createScaledBitmap(rawAlphaBitmap, nativeWidth, nativeHeight, true)
        if (rawAlphaBitmap != scaledMask) {
            rawAlphaBitmap.recycle()
        }

        // 5. Apply 2px Gaussian blur feathering across mask edges to eliminate jagged boundaries
        val featheredMask = applyGaussianBlur(scaledMask, radius = 2)
        if (scaledMask != featheredMask) {
            scaledMask.recycle()
        }

        coroutineContext.ensureActive()

        // 6. Composite native high-res bitmap with feathered alpha mask using DST_IN Porter-Duff mode
        val outputBitmap = Bitmap.createBitmap(nativeWidth, nativeHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(outputBitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)

        // Draw original high-res content
        canvas.drawBitmap(inputBitmap, 0f, 0f, paint)

        // Mask out background while preserving smooth feathered foreground alpha
        paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.DST_IN)
        canvas.drawBitmap(featheredMask, 0f, 0f, paint)
        paint.xfermode = null

        featheredMask.recycle()
        if (mlBitmap != inputBitmap) {
            mlBitmap.recycle()
        }

        outputBitmap
    }

    /**
     * Fast 2D separable Gaussian blur filter to feather mask edges.
     */
    private fun applyGaussianBlur(src: Bitmap, radius: Int): Bitmap {
        if (radius < 1) return src
        val width = src.width
        val height = src.height
        val output = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)

        val pixels = IntArray(width * height)
        val temp = IntArray(width * height)
        src.getPixels(pixels, 0, width, 0, 0, width, height)

        val kernel = getGaussianKernel(radius)
        val kernelSize = kernel.size
        val half = kernelSize / 2

        // Horizontal blur pass
        for (y in 0 until height) {
            val yOffset = y * width
            for (x in 0 until width) {
                var a = 0f
                for (k in -half..half) {
                    val px = (x + k).coerceIn(0, width - 1)
                    val color = pixels[yOffset + px]
                    val alpha = (color ushr 24) and 0xFF
                    val weight = kernel[k + half]
                    a += alpha * weight
                }
                val finalAlpha = a.toInt().coerceIn(0, 255)
                temp[yOffset + x] = (finalAlpha shl 24) or 0x00FFFFFF
            }
        }

        // Vertical blur pass
        for (x in 0 until width) {
            for (y in 0 until height) {
                var a = 0f
                for (k in -half..half) {
                    val py = (y + k).coerceIn(0, height - 1)
                    val color = temp[py * width + x]
                    val alpha = (color ushr 24) and 0xFF
                    val weight = kernel[k + half]
                    a += alpha * weight
                }
                val finalAlpha = a.toInt().coerceIn(0, 255)
                pixels[y * width + x] = (finalAlpha shl 24) or 0x00FFFFFF
            }
        }

        output.setPixels(pixels, 0, width, 0, 0, width, height)
        return output
    }

    private fun getGaussianKernel(radius: Int): FloatArray {
        val size = radius * 2 + 1
        val kernel = FloatArray(size)
        val sigma = radius / 2.0f
        var sum = 0f

        for (i in 0 until size) {
            val x = i - radius
            val g = Math.exp(-(x * x) / (2.0 * sigma * sigma)).toFloat()
            kernel[i] = g
            sum += g
        }
        for (i in 0 until size) {
            kernel[i] /= sum
        }
        return kernel
    }

    /**
     * Corrects camera EXIF rotation before processing.
     */
    fun correctExifOrientation(bitmap: Bitmap, inputStream: InputStream): Bitmap {
        val exif = ExifInterface(inputStream)
        val orientation = exif.getAttributeInt(
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.ORIENTATION_NORMAL
        )
        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.preScale(-1f, 1f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.preScale(1f, -1f)
            else -> return bitmap
        }
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }
}
