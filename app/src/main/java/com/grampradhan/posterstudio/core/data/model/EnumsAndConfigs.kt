package com.grampradhan.posterstudio.core.data.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
enum class TemplateCategory : Parcelable {
    ALL,
    ELECTION_CAMPAIGN,
    FESTIVAL_GREETINGS,
    VIKAS_KARYA,
    BIRTHDAY_CONGRATULATIONS
}

@Parcelize
enum class AspectRatio(val widthRatio: Float, val heightRatio: Float) : Parcelable {
    SQUARE_1_1(1f, 1f),          // 1080x1080 (Square Social Post)
    PORTRAIT_9_16(9f, 16f),      // 1080x1920 (WhatsApp Status / Story)
    BANNER_2_1(2f, 1f),          // 3600x1800 (Horizontal Flex Banner)
    BANNER_3_1(3f, 1f)           // 3600x1200 (Long Wall Banner)
}

@Parcelize
enum class SlotType : Parcelable {
    CANDIDATE_PHOTO,
    PARTY_SYMBOL,
    LEADER_PORTRAIT,
    VILLAGE_TEXT
}

@Parcelize
data class TextLayerConfig(
    val layerId: String,
    val text: String,
    val fontName: String = "Rozha One",
    val colorHex: String = "#FFFFFF",
    val strokeColorHex: String = "#000000",
    val strokeWidthDp: Float = 0f,
    val fontSizeSp: Float = 24f,
    val xRatio: Float = 0.5f,
    val yRatio: Float = 0.5f,
    val alignment: String = "CENTER",
    val isEditable: Boolean = true
) : Parcelable

@Parcelize
data class ImageSlotConfig(
    val slotId: String,
    val slotType: SlotType,
    val xRatio: Float,
    val yRatio: Float,
    val widthRatio: Float,
    val heightRatio: Float,
    val zIndex: Int = 0
) : Parcelable

@Parcelize
data class LayerSnapshot(
    val layerId: String,
    val type: String,               // "TEXT", "IMAGE", "STICKER", "BACKGROUND"
    val zIndex: Int,
    val translationX: Float,
    val translationY: Float,
    val scale: Float = 1f,
    val rotation: Float = 0f,
    val isLocked: Boolean = false,
    val textContent: String? = null,
    val textColorHex: String? = null,
    val fontName: String? = null,
    val fontSizeSp: Float? = null,
    val strokeWidthDp: Float? = null,
    val strokeColorHex: String? = null,
    val curveArc: Float? = null,
    val imageUriOrPath: String? = null
) : Parcelable
