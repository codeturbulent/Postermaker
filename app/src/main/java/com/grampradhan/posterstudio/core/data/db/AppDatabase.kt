package com.grampradhan.posterstudio.core.data.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
import com.grampradhan.posterstudio.core.data.model.PosterDraft
import com.grampradhan.posterstudio.core.data.model.PosterTemplate

@Database(
    entities = [
        CandidateProfile::class,
        PosterTemplate::class,
        PosterDraft::class
    ],
    version = 1,
    exportSchema = false
)
@TypeConverters(
    ListStringConverter::class,
    TextLayerConverter::class,
    ImageSlotConverter::class,
    LayerSnapshotConverter::class,
    EnumConverters::class
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun candidateProfileDao(): CandidateProfileDao
    abstract fun templateDao(): TemplateDao
    abstract fun draftDao(): DraftDao

    companion object {
        const val DATABASE_NAME = "gram_pradhan_studio.db"
    }
}
