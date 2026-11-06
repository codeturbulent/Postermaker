package com.grampradhan.posterstudio.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grampradhan.posterstudio.core.data.db.CandidateProfileDao
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
import com.grampradhan.posterstudio.core.data.model.PosterTemplate
import com.grampradhan.posterstudio.core.data.model.TemplateCategory
import com.grampradhan.posterstudio.core.data.repository.TemplateRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import javax.inject.Inject

data class HomeUiState(
    val activeProfile: CandidateProfile? = null,
    val selectedCategory: TemplateCategory = TemplateCategory.ALL,
    val templates: List<PosterTemplate> = emptyList(),
    val isLoading: Boolean = false
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val candidateProfileDao: CandidateProfileDao,
    private val templateRepository: TemplateRepository
) : ViewModel() {

    private val _selectedCategory = MutableStateFlow(TemplateCategory.ALL)
    val selectedCategory: StateFlow<TemplateCategory> = _selectedCategory.asStateFlow()

    val uiState: StateFlow<HomeUiState> = combine(
        candidateProfileDao.observeActiveProfile(),
        _selectedCategory.flatMapLatest { category ->
            templateRepository.getTemplates(category)
        },
        _selectedCategory
    ) { profile, templates, category ->
        HomeUiState(
            activeProfile = profile,
            selectedCategory = category,
            templates = templates,
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
}
