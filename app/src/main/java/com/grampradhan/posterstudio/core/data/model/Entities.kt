package com.grampradhan.posterstudio.core.data.model

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverters
import com.grampradhan.posterstudio.core.data.db.ImageSlotConverter
import com.grampradhan.posterstudio.core.data.db.LayerSnapshotConverter
import com.grampradhan.posterstudio.core.data.db.ListStringConverter
import com.grampradhan.posterstudio.core.data.db.TextLayerConverter
import kotlinx.parcelize.Parcelize

/**
 * Represents the brand kit and identity of the candidate or panchayat representative.
 */
@Parcelize
@Entity(tableName = "candidate_profiles")
data class CandidateProfile(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val candidateName: String,           // "राम सिंह यादव"
    val designation: String,             // "भावी ग्राम प्रधान प्रत्याशी"
    val gramPanchayat: String,
    val vikasKhandBlock: String,
    val district: String,
    val slogan: String,
    val candidatePhotoPath: String?,     // cutout PNG path
    val partySymbolPath: String?,
    @TypeConverters(ListStringConverter::class)
    val leaderPhotos: List<String> = emptyList(),
    val primaryColorHex: String = "#FF6A1B",
    val phoneNumber: String = "",
    val updatedAt: Long = System.currentTimeMillis()
) : Parcelable

/**
 * Predefined election or festival poster template.
 */
@Parcelize
@Entity(tableName = "poster_templates")
data class PosterTemplate(
    @PrimaryKey val id: String,
    val category: TemplateCategory,
    val aspectRatio: AspectRatio,
    val backgroundUrl: String,           // asset:// or file://
    val thumbUrl: String,
    @TypeConverters(TextLayerConverter::class)
    val predefinedTextLayers: List<TextLayerConfig>,
    @TypeConverters(ImageSlotConverter::class)
    val slotConfigs: List<ImageSlotConfig>,
    val isPro: Boolean = false
) : Parcelable

/**
 * User draft saved locally for resume-editing.
 */
@Parcelize
@Entity(tableName = "poster_drafts")
data class PosterDraft(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val templateId: String,
    @TypeConverters(LayerSnapshotConverter::class)
    val layers: List<LayerSnapshot>,     // serialized editor state
    val previewPath: String,
    val savedAt: Long = System.currentTimeMillis()
) : Parcelable
