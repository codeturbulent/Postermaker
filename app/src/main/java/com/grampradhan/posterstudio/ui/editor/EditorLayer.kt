package com.grampradhan.posterstudio.ui.editor

import android.graphics.Bitmap
import android.graphics.Typeface
import androidx.compose.ui.graphics.Color
import java.util.UUID

sealed class EditorLayer(
    open val id: String = UUID.randomUUID().toString(),
    open val name: String,
    open val zIndex: Int,
    open val translationX: Float = 0f,
    open val translationY: Float = 0f,
    open val scale: Float = 1f,
    open val rotation: Float = 0f,
    open val isFlippedHorizontal: Boolean = false,
    open val isLocked: Boolean = false
) {
    abstract fun copyWithTransform(
        translationX: Float = this.translationX,
        translationY: Float = this.translationY,
        scale: Float = this.scale,
        rotation: Float = this.rotation,
        isFlippedHorizontal: Boolean = this.isFlippedHorizontal,
        zIndex: Int = this.zIndex,
        isLocked: Boolean = this.isLocked
    ): EditorLayer

    data class BackgroundLayer(
        override val id: String = "bg_layer",
        override val name: String = "पृष्ठभूमि (Background)",
        override val zIndex: Int = 0,
        val color: Int = android.graphics.Color.WHITE,
        val bitmap: Bitmap? = null,
        val backgroundUrl: String? = null
    ) : EditorLayer(id, name, zIndex, 0f, 0f, 1f, 0f, false, true) {
        override fun copyWithTransform(
            translationX: Float,
            translationY: Float,
            scale: Float,
            rotation: Float,
            isFlippedHorizontal: Boolean,
            zIndex: Int,
            isLocked: Boolean
        ): BackgroundLayer = this.copy(zIndex = zIndex)
    }

    data class TextLayer(
        override val id: String = UUID.randomUUID().toString(),
        override val name: String = "टेक्स्ट",
        override val zIndex: Int,
        override val translationX: Float = 0f,
        override val translationY: Float = 0f,
        override val scale: Float = 1f,
        override val rotation: Float = 0f,
        override val isFlippedHorizontal: Boolean = false,
        override val isLocked: Boolean = false,
        val text: String,
        val fontName: String = "Rozha One",
        val typeface: Typeface = Typeface.DEFAULT_BOLD,
        val textColor: Int = android.graphics.Color.WHITE,
        val fontSizeSp: Float = 28f,
        val strokeColor: Int = android.graphics.Color.BLACK,
        val strokeWidthDp: Float = 2f,
        val hasShadow: Boolean = true,
        val curvedArc: Float = 0f, // -180f to +180f
        val lineHeightMultiplier: Float = 1.2f,
        val letterSpacingEm: Float = 0.05f
    ) : EditorLayer(id, name, zIndex, translationX, translationY, scale, rotation, isFlippedHorizontal, isLocked) {
        override fun copyWithTransform(
            translationX: Float,
            translationY: Float,
            scale: Float,
            rotation: Float,
            isFlippedHorizontal: Boolean,
            zIndex: Int,
            isLocked: Boolean
        ): TextLayer = this.copy(
            translationX = translationX,
            translationY = translationY,
            scale = scale,
            rotation = rotation,
            isFlippedHorizontal = isFlippedHorizontal,
            zIndex = zIndex,
            isLocked = isLocked
        )
    }

    data class ImageLayer(
        override val id: String = UUID.randomUUID().toString(),
        override val name: String = "फ़ोटो",
        override val zIndex: Int,
        override val translationX: Float = 0f,
        override val translationY: Float = 0f,
        override val scale: Float = 1f,
        override val rotation: Float = 0f,
        override val isFlippedHorizontal: Boolean = false,
        override val isLocked: Boolean = false,
        val bitmap: Bitmap? = null,
        val imagePath: String? = null
    ) : EditorLayer(id, name, zIndex, translationX, translationY, scale, rotation, isFlippedHorizontal, isLocked) {
        override fun copyWithTransform(
            translationX: Float,
            translationY: Float,
            scale: Float,
            rotation: Float,
            isFlippedHorizontal: Boolean,
            zIndex: Int,
            isLocked: Boolean
        ): ImageLayer = this.copy(
            translationX = translationX,
            translationY = translationY,
            scale = scale,
            rotation = rotation,
            isFlippedHorizontal = isFlippedHorizontal,
            zIndex = zIndex,
            isLocked = isLocked
        )
    }

    data class StickerLayer(
        override val id: String = UUID.randomUUID().toString(),
        override val name: String = "चुनाव चिन्ह / स्टिकर",
        override val zIndex: Int,
        override val translationX: Float = 0f,
        override val translationY: Float = 0f,
        override val scale: Float = 1f,
        override val rotation: Float = 0f,
        override val isFlippedHorizontal: Boolean = false,
        override val isLocked: Boolean = false,
        val bitmap: Bitmap? = null,
        val symbolKey: String? = null
    ) : EditorLayer(id, name, zIndex, translationX, translationY, scale, rotation, isFlippedHorizontal, isLocked) {
        override fun copyWithTransform(
            translationX: Float,
            translationY: Float,
            scale: Float,
            rotation: Float,
            isFlippedHorizontal: Boolean,
            zIndex: Int,
            isLocked: Boolean
        ): StickerLayer = this.copy(
            translationX = translationX,
            translationY = translationY,
            scale = scale,
            rotation = rotation,
            isFlippedHorizontal = isFlippedHorizontal,
            zIndex = zIndex,
            isLocked = isLocked
        )
    }
}
