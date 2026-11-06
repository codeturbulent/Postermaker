package com.grampradhan.posterstudio.core.data.di

import android.content.Context
import androidx.room.Room
import com.grampradhan.posterstudio.core.data.db.AppDatabase
import com.grampradhan.posterstudio.core.data.db.CandidateProfileDao
import com.grampradhan.posterstudio.core.data.db.DraftDao
import com.grampradhan.posterstudio.core.data.db.TemplateDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideAppDatabase(@ApplicationContext context: Context): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            AppDatabase.DATABASE_NAME
        )
        .fallbackToDestructiveMigration()
        .build()
    }

    @Provides
    @Singleton
    fun provideCandidateProfileDao(database: AppDatabase): CandidateProfileDao {
        return database.candidateProfileDao()
    }

    @Provides
    @Singleton
    fun provideTemplateDao(database: AppDatabase): TemplateDao {
        return database.templateDao()
    }

    @Provides
    @Singleton
    fun provideDraftDao(database: AppDatabase): DraftDao {
        return database.draftDao()
    }
}
