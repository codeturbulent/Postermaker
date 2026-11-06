package com.grampradhan.posterstudio.ui.profile

import app.cash.turbine.test
import com.grampradhan.posterstudio.core.data.db.CandidateProfileDao
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
import com.grampradhan.posterstudio.ml.MLKitBackgroundRemover
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class ProfileViewModelTest {

    private val testDispatcher = StandardTestDispatcher()
    private val candidateProfileDao: CandidateProfileDao = mockk(relaxed = true)
    private val backgroundRemover: MLKitBackgroundRemover = mockk(relaxed = true)

    @BeforeEach
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        coEvery { candidateProfileDao.getActiveProfile() } returns null
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    @DisplayName("UDF Validation: Save remains disabled until name and gram panchayat are valid")
    fun testValidationEnforcesRequiredFields() = runTest {
        val viewModel = ProfileViewModel(candidateProfileDao, backgroundRemover)
        testDispatcher.scheduler.advanceUntilIdle()

        viewModel.uiState.test {
            val initial = awaitItem() as ProfileUiState.Content
            assertFalse(initial.isSaveEnabled)

            // 1. Enter Candidate Name only
            viewModel.onIntent(ProfileIntent.NameChanged("राम सिंह"))
            val withName = awaitItem() as ProfileUiState.Content
            assertEquals("राम सिंह", withName.candidateName)
            assertNull(withName.nameErrorHindi)
            assertFalse(withName.isSaveEnabled) // Panchayat still empty

            // 2. Clear Name - triggers validation error in Hindi
            viewModel.onIntent(ProfileIntent.NameChanged(""))
            val errorState = awaitItem() as ProfileUiState.Content
            assertEquals("कृपया प्रत्याशी का नाम दर्ज करें", errorState.nameErrorHindi)
            assertFalse(errorState.isSaveEnabled)

            // 3. Enter valid Name and Panchayat
            viewModel.onIntent(ProfileIntent.NameChanged("राम सिंह यादव"))
            awaitItem() // Name state
            viewModel.onIntent(ProfileIntent.GramPanchayatChanged("रामपुर"))
            val validState = awaitItem() as ProfileUiState.Content

            assertEquals("रामपुर", validState.gramPanchayat)
            assertNull(validState.panchayatErrorHindi)
            assertTrue(validState.isSaveEnabled)

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    @DisplayName("Save Intent: Inserts candidate profile into Room database")
    fun testSaveProfilePersistsToDao() = runTest {
        val viewModel = ProfileViewModel(candidateProfileDao, backgroundRemover)
        testDispatcher.scheduler.advanceUntilIdle()

        viewModel.onIntent(ProfileIntent.NameChanged("सुरेश कुमार"))
        viewModel.onIntent(ProfileIntent.GramPanchayatChanged("शिवपुर"))
        viewModel.onIntent(ProfileIntent.BlockChanged("केराकत"))
        viewModel.onIntent(ProfileIntent.DistrictChanged("जौनपुर"))
        viewModel.onIntent(ProfileIntent.SaveProfile)

        testDispatcher.scheduler.advanceUntilIdle()

        coVerify(exactly = 1) {
            candidateProfileDao.insertOrUpdate(
                match { profile ->
                    profile.candidateName == "सुरेश कुमार" &&
                    profile.gramPanchayat == "शिवपुर" &&
                    profile.vikasKhandBlock == "केराकत" &&
                    profile.district == "जौनपुर"
                }
            )
        }
    }
}
