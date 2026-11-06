package com.grampradhan.posterstudio.core.data.db

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.grampradhan.posterstudio.core.data.model.PosterDraft
import kotlinx.coroutines.flow.Flow

@Dao
interface DraftDao {

    @Query("SELECT * FROM poster_drafts ORDER BY savedAt DESC")
    fun getAllDrafts(): Flow<List<PosterDraft>>

    @Query("SELECT * FROM poster_drafts WHERE id = :id")
    fun getDraftById(id: Long): Flow<PosterDraft?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertDraft(draft: PosterDraft): Long

    @Delete
    suspend fun deleteDraft(draft: PosterDraft)

    @Query("DELETE FROM poster_drafts WHERE id = :id")
    suspend fun deleteDraftById(id: Long)
}
