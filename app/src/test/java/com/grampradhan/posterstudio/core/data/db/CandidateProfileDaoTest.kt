package com.grampradhan.posterstudio.core.data.db

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import app.cash.turbine.test
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [34])
class CandidateProfileDaoTest {

    private lateinit var database: AppDatabase
    private lateinit var dao: CandidateProfileDao

    @Before
    fun setup() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        database = Room.inMemoryDatabaseBuilder(context, AppDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        dao = database.candidateProfileDao()
    }

    @After
    fun teardown() {
        database.close()
    }

    @Test
    fun insertAndObserveActiveProfile_emitsLatestUpdatedProfile() = runBlocking {
        dao.observeActiveProfile().test {
            // Initial state: No profile exists
            assertNull(awaitItem())

            // Insert initial profile
            val profile1 = CandidateProfile(
                id = 1,
                candidateName = "राम सिंह यादव",
                designation = "ग्राम प्रधान",
                gramPanchayat = "रामपुर",
                vikasKhandBlock = "बक्शा",
                district = "जौनपुर",
                slogan = "गाँव का विकास",
                candidatePhotoPath = null,
                partySymbolPath = "ट्रैक्टर",
                updatedAt = 1000L
            )
            dao.insertOrUpdate(profile1)

            val emitted1 = awaitItem()
            assertNotNull(emitted1)
            assertEquals("राम सिंह यादव", emitted1?.candidateName)
            assertEquals("ग्राम प्रधान", emitted1?.designation)

            // Insert newer profile with higher updatedAt timestamp
            val profile2 = CandidateProfile(
                id = 2,
                candidateName = "श्रीमती सरिता देवी",
                designation = "भावी प्रत्याशी",
                gramPanchayat = "रामपुर",
                vikasKhandBlock = "बक्शा",
                district = "जौनपुर",
                slogan = "स्वच्छ रामपुर, सुंदर रामपुर",
                candidatePhotoPath = null,
                partySymbolPath = "सूरजमुखी",
                updatedAt = 2000L
            )
            dao.insertOrUpdate(profile2)

            val emitted2 = awaitItem()
            assertNotNull(emitted2)
            assertEquals("श्रीमती सरिता देवी", emitted2?.candidateName)
            assertEquals(2L, emitted2?.id)

            cancelAndIgnoreRemainingEvents()
        }
    }
}
