package com.grampradhan.posterstudio.core.data.repository

import com.grampradhan.posterstudio.core.data.db.TemplateDao
import com.grampradhan.posterstudio.core.data.model.PosterTemplate
import com.grampradhan.posterstudio.core.data.model.TemplateCategory
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.onStart
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TemplateRepository @Inject constructor(
    private val templateDao: TemplateDao
) {
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO

    fun getTemplates(category: TemplateCategory = TemplateCategory.ALL): Flow<List<PosterTemplate>> {
        return (if (category == TemplateCategory.ALL) {
            templateDao.getAllTemplates()
        } else {
            templateDao.getTemplatesByCategory(category)
        })
        .onStart {
            ensureSeeded()
        }
        .flowOn(ioDispatcher)
    }

    suspend fun getTemplateById(id: String): PosterTemplate? = withContext(ioDispatcher) {
        ensureSeeded()
        // Fallback to in-memory bundle if not yet indexed in Room
        TemplateSeeder.BUNDLED_TEMPLATES.find { it.id == id }
    }

    private suspend fun ensureSeeded() = withContext(ioDispatcher) {
        templateDao.insertTemplates(TemplateSeeder.BUNDLED_TEMPLATES)
    }
}
