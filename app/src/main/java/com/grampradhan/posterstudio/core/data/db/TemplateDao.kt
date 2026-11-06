package com.grampradhan.posterstudio.core.data.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.grampradhan.posterstudio.core.data.model.PosterTemplate
import com.grampradhan.posterstudio.core.data.model.TemplateCategory
import kotlinx.coroutines.flow.Flow

@Dao
interface TemplateDao {

    @Query("SELECT * FROM poster_templates")
    fun getAllTemplates(): Flow<List<PosterTemplate>>

    @Query("SELECT * FROM poster_templates WHERE category = :category")
    fun getTemplatesByCategory(category: TemplateCategory): Flow<List<PosterTemplate>>

    @Query("SELECT * FROM poster_templates WHERE id = :id")
    fun getTemplateById(id: String): Flow<PosterTemplate?>

    @Query("SELECT * FROM poster_templates WHERE isPro = 0")
    fun getFreeTemplates(): Flow<List<PosterTemplate>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTemplates(templates: List<PosterTemplate>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTemplate(template: PosterTemplate)
}
