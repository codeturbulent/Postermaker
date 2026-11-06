package com.grampradhan.posterstudio.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grampradhan.posterstudio.core.data.db.CandidateProfileDao
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
import com.grampradhan.posterstudio.core.data.model.PosterTemplate
import com.grampradhan.posterstudio.core.data.model.TemplateCategory
import com.grampradhan.posterstudio.core.data.model.UpcomingOccasion
import com.grampradhan.posterstudio.core.data.repository.TemplateRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

data class HomeUiState(
    val activeProfile: CandidateProfile? = null,
    val allProfiles: List<CandidateProfile> = emptyList(),
    val selectedCategory: TemplateCategory = TemplateCategory.ALL,
    val templates: List<PosterTemplate> = emptyList(),
    val upcomingOccasions: List<UpcomingOccasion> = UpcomingOccasion.PRESET_OCCASIONS,
    val isProfileSwitcherVisible: Boolean = false,
    val isLoading: Boolean = false
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val candidateProfileDao: CandidateProfileDao,
    private val templateRepository: TemplateRepository
) : ViewModel() {

    private val _selectedCategory = MutableStateFlow(TemplateCategory.ALL)
    val selectedCategory: StateFlow<TemplateCategory> = _selectedCategory.asStateFlow()

    private val _isProfileSwitcherVisible = MutableStateFlow(false)

    init {
        ensureInitialSampleProfile()
    }

    private fun ensureInitialSampleProfile() {
        viewModelScope.launch {
            val existing = candidateProfileDao.getActiveProfile()
            if (existing == null) {
                val sample = CandidateProfile(
                    candidateName = "राजेश कुमार यादव",
                    designation = "ग्राम प्रधान",
                    gramPanchayat = "बलीपुर",
                    vikasKhandBlock = "बक्शा",
                    district = "जौनपुर",
                    slogan = "आपकी सेवा में सदैव तत्पर, गाँव का संपूर्ण विकास",
                    candidatePhotoPath = null,
                    partySymbolPath = "ट्रैक्टर",
                    phoneNumber = "+91 98765 43210"
                )
                candidateProfileDao.insertOrUpdate(sample)
            }
        }
    }

    val uiState: StateFlow<HomeUiState> = combine(
        candidateProfileDao.observeActiveProfile(),
        candidateProfileDao.observeAllProfiles(),
        _selectedCategory.flatMapLatest { category ->
            templateRepository.getTemplates(category)
        },
        _selectedCategory,
        _isProfileSwitcherVisible
    ) { activeProfile, allProfiles, templates, category, isSwitcherVisible ->
        HomeUiState(
            activeProfile = activeProfile,
            allProfiles = allProfiles,
            selectedCategory = category,
            templates = templates,
            isProfileSwitcherVisible = isSwitcherVisible,
            isLoading = false
        )
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = HomeUiState(isLoading = true)
    )

    fun onSelectCategory(category: TemplateCategory) {
        _selectedCategory.value = category
    }

    fun toggleProfileSwitcher(visible: Boolean) {
        _isProfileSwitcherVisible.value = visible
    }

    fun switchActiveProfile(profileId: Long) {
        viewModelScope.launch {
            candidateProfileDao.setActiveProfile(profileId)
            _isProfileSwitcherVisible.value = false
        }
    }
}
