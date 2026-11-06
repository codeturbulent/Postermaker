package com.grampradhan.posterstudio.core.data.db

import androidx.room.TypeConverter
import com.grampradhan.posterstudio.core.data.model.AspectRatio
import com.grampradhan.posterstudio.core.data.model.ImageSlotConfig
import com.grampradhan.posterstudio.core.data.model.LayerSnapshot
import com.grampradhan.posterstudio.core.data.model.SlotType
import com.grampradhan.posterstudio.core.data.model.TemplateCategory
import com.grampradhan.posterstudio.core.data.model.TextLayerConfig
import org.json.JSONArray
import org.json.JSONObject

class ListStringConverter {
    @TypeConverter
    fun fromList(list: List<String>?): String {
        if (list.isNullOrEmpty()) return "[]"
        val array = JSONArray()
        list.forEach { array.put(it) }
        return array.toString()
    }

    @TypeConverter
    fun toList(json: String?): List<String> {
        if (json.isNullOrBlank()) return emptyList()
        val list = mutableListOf<String>()
        val array = JSONArray(json)
        for (i in 0 until array.length()) {
            list.add(array.getString(i))
        }
        return list
    }
}

class TextLayerConverter {
    @TypeConverter
    fun fromList(list: List<TextLayerConfig>?): String {
        if (list.isNullOrEmpty()) return "[]"
        val array = JSONArray()
        for (item in list) {
            val obj = JSONObject().apply {
                put("layerId", item.layerId)
                put("text", item.text)
                put("fontName", item.fontName)
                put("colorHex", item.colorHex)
                put("strokeColorHex", item.strokeColorHex)
                put("strokeWidthDp", item.strokeWidthDp.toDouble())
                put("fontSizeSp", item.fontSizeSp.toDouble())
                put("xRatio", item.xRatio.toDouble())
                put("yRatio", item.yRatio.toDouble())
                put("alignment", item.alignment)
                put("isEditable", item.isEditable)
            }
            array.put(obj)
        }
        return array.toString()
    }

    @TypeConverter
    fun toList(json: String?): List<TextLayerConfig> {
        if (json.isNullOrBlank()) return emptyList()
        val list = mutableListOf<TextLayerConfig>()
        val array = JSONArray(json)
        for (i in 0 until array.length()) {
            val obj = array.getJSONObject(i)
            list.add(
                TextLayerConfig(
                    layerId = obj.getString("layerId"),
                    text = obj.getString("text"),
                    fontName = obj.optString("fontName", "Rozha One"),
                    colorHex = obj.optString("colorHex", "#FFFFFF"),
                    strokeColorHex = obj.optString("strokeColorHex", "#000000"),
                    strokeWidthDp = obj.optDouble("strokeWidthDp", 0.0).toFloat(),
                    fontSizeSp = obj.optDouble("fontSizeSp", 24.0).toFloat(),
                    xRatio = obj.optDouble("xRatio", 0.5).toFloat(),
                    yRatio = obj.optDouble("yRatio", 0.5).toFloat(),
                    alignment = obj.optString("alignment", "CENTER"),
                    isEditable = obj.optBoolean("isEditable", true)
                )
            )
        }
        return list
    }
}

class ImageSlotConverter {
    @TypeConverter
    fun fromList(list: List<ImageSlotConfig>?): String {
        if (list.isNullOrEmpty()) return "[]"
        val array = JSONArray()
        for (item in list) {
            val obj = JSONObject().apply {
                put("slotId", item.slotId)
                put("slotType", item.slotType.name)
                put("xRatio", item.xRatio.toDouble())
                put("yRatio", item.yRatio.toDouble())
                put("widthRatio", item.widthRatio.toDouble())
                put("heightRatio", item.heightRatio.toDouble())
                put("zIndex", item.zIndex)
            }
            array.put(obj)
        }
        return array.toString()
    }

    @TypeConverter
    fun toList(json: String?): List<ImageSlotConfig> {
        if (json.isNullOrBlank()) return emptyList()
        val list = mutableListOf<ImageSlotConfig>()
        val array = JSONArray(json)
        for (i in 0 until array.length()) {
            val obj = array.getJSONObject(i)
            list.add(
                ImageSlotConfig(
                    slotId = obj.getString("slotId"),
                    slotType = SlotType.valueOf(obj.getString("slotType")),
                    xRatio = obj.getDouble("xRatio").toFloat(),
                    yRatio = obj.getDouble("yRatio").toFloat(),
                    widthRatio = obj.getDouble("widthRatio").toFloat(),
                    heightRatio = obj.getDouble("heightRatio").toFloat(),
                    zIndex = obj.optInt("zIndex", 0)
                )
            )
        }
        return list
    }
}

class LayerSnapshotConverter {
    @TypeConverter
    fun fromList(list: List<LayerSnapshot>?): String {
        if (list.isNullOrEmpty()) return "[]"
        val array = JSONArray()
        for (item in list) {
            val obj = JSONObject().apply {
                put("layerId", item.layerId)
                put("type", item.type)
                put("zIndex", item.zIndex)
                put("translationX", item.translationX.toDouble())
                put("translationY", item.translationY.toDouble())
                put("scale", item.scale.toDouble())
                put("rotation", item.rotation.toDouble())
                put("isLocked", item.isLocked)
                put("textContent", item.textContent ?: JSONObject.NULL)
                put("textColorHex", item.textColorHex ?: JSONObject.NULL)
                put("fontName", item.fontName ?: JSONObject.NULL)
                put("fontSizeSp", item.fontSizeSp?.toDouble() ?: JSONObject.NULL)
                put("strokeWidthDp", item.strokeWidthDp?.toDouble() ?: JSONObject.NULL)
                put("strokeColorHex", item.strokeColorHex ?: JSONObject.NULL)
                put("curveArc", item.curveArc?.toDouble() ?: JSONObject.NULL)
                put("imageUriOrPath", item.imageUriOrPath ?: JSONObject.NULL)
            }
            array.put(obj)
        }
        return array.toString()
    }

    @TypeConverter
    fun toList(json: String?): List<LayerSnapshot> {
        if (json.isNullOrBlank()) return emptyList()
        val list = mutableListOf<LayerSnapshot>()
        val array = JSONArray(json)
        for (i in 0 until array.length()) {
            val obj = array.getJSONObject(i)
            list.add(
                LayerSnapshot(
                    layerId = obj.getString("layerId"),
                    type = obj.getString("type"),
                    zIndex = obj.getInt("zIndex"),
                    translationX = obj.getDouble("translationX").toFloat(),
                    translationY = obj.getDouble("translationY").toFloat(),
                    scale = obj.optDouble("scale", 1.0).toFloat(),
                    rotation = obj.optDouble("rotation", 0.0).toFloat(),
                    isLocked = obj.optBoolean("isLocked", false),
                    textContent = if (obj.isNull("textContent")) null else obj.getString("textContent"),
                    textColorHex = if (obj.isNull("textColorHex")) null else obj.getString("textColorHex"),
                    fontName = if (obj.isNull("fontName")) null else obj.getString("fontName"),
                    fontSizeSp = if (obj.isNull("fontSizeSp")) null else obj.getDouble("fontSizeSp").toFloat(),
                    strokeWidthDp = if (obj.isNull("strokeWidthDp")) null else obj.getDouble("strokeWidthDp").toFloat(),
                    strokeColorHex = if (obj.isNull("strokeColorHex")) null else obj.getString("strokeColorHex"),
                    curveArc = if (obj.isNull("curveArc")) null else obj.getDouble("curveArc").toFloat(),
                    imageUriOrPath = if (obj.isNull("imageUriOrPath")) null else obj.getString("imageUriOrPath")
                )
            )
        }
        return list
    }
}

class EnumConverters {
    @TypeConverter
    fun fromCategory(category: TemplateCategory?): String = category?.name ?: TemplateCategory.ALL.name

    @TypeConverter
    fun toCategory(value: String?): TemplateCategory = runCatching {
        TemplateCategory.valueOf(value ?: TemplateCategory.ALL.name)
    }.getOrDefault(TemplateCategory.ALL)

    @TypeConverter
    fun fromAspectRatio(ratio: AspectRatio?): String = ratio?.name ?: AspectRatio.SQUARE_1_1.name

    @TypeConverter
    fun toAspectRatio(value: String?): AspectRatio = runCatching {
        AspectRatio.valueOf(value ?: AspectRatio.SQUARE_1_1.name)
    }.getOrDefault(AspectRatio.SQUARE_1_1)
}
