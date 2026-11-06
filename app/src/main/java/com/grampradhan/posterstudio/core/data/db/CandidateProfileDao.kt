package com.grampradhan.posterstudio.core.data.db

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
import kotlinx.coroutines.flow.Flow

@Dao
interface CandidateProfileDao {

    @Query("SELECT * FROM candidate_profiles ORDER BY updatedAt DESC")
    fun observeAllProfiles(): Flow<List<CandidateProfile>>

    @Query("SELECT * FROM candidate_profiles ORDER BY updatedAt DESC")
    suspend fun getAllProfiles(): List<CandidateProfile>

    @Query("SELECT * FROM candidate_profiles ORDER BY updatedAt DESC LIMIT 1")
    fun observeActiveProfile(): Flow<CandidateProfile?>

    @Query("SELECT * FROM candidate_profiles ORDER BY updatedAt DESC LIMIT 1")
    suspend fun getActiveProfile(): CandidateProfile?

    @Query("SELECT * FROM candidate_profiles WHERE id = :id")
    suspend fun getProfileById(id: Long): CandidateProfile?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrUpdate(profile: CandidateProfile): Long

    @Update
    suspend fun updateProfile(profile: CandidateProfile)

    @Delete
    suspend fun deleteProfile(profile: CandidateProfile)

    @Query("UPDATE candidate_profiles SET updatedAt = :timestamp WHERE id = :id")
    suspend fun setActiveProfile(id: Long, timestamp: Long = System.currentTimeMillis())

    @Query("DELETE FROM candidate_profiles")
    suspend fun clearAllProfiles()
}
