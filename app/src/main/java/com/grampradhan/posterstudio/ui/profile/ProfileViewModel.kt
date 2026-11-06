package com.grampradhan.posterstudio.ui.profile

import android.graphics.Bitmap
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grampradhan.posterstudio.core.data.db.CandidateProfileDao
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
import com.grampradhan.posterstudio.ml.MLKitBackgroundRemover
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface ProfileIntent {
    data class NameChanged(val name: String) : ProfileIntent
    data class DesignationChanged(val designation: String) : ProfileIntent
    data class CustomDesignationChanged(val custom: String) : ProfileIntent
    data class GramPanchayatChanged(val panchayat: String) : ProfileIntent
    data class BlockChanged(val block: String) : ProfileIntent
    data class DistrictChanged(val district: String) : ProfileIntent
    data class SloganChanged(val slogan: String) : ProfileIntent
    data class PhoneChanged(val phone: String) : ProfileIntent
    data class PhotoSelected(val bitmap: Bitmap) : ProfileIntent
    data class ToggleRemoveBackground(val enabled: Boolean) : ProfileIntent
    data class PartySymbolSelected(val symbol: String) : ProfileIntent
    data class PrimaryColorSelected(val colorHex: String) : ProfileIntent
    data object SaveProfile : ProfileIntent
}

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val candidateProfileDao: CandidateProfileDao,
    private val backgroundRemover: MLKitBackgroundRemover
) : ViewModel() {

    private val _uiState = MutableStateFlow<ProfileUiState>(ProfileUiState.Loading)
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    init {
        loadExistingProfile()
    }

    private fun loadExistingProfile() {
        viewModelScope.launch {
            val existing = candidateProfileDao.getActiveProfile()
            if (existing != null) {
                val isCustom = !ProfileUiState.DESIGNATION_PRESETS.contains(existing.designation)
                _uiState.value = ProfileUiState.Content(
                    candidateName = existing.candidateName,
                    designation = if (isCustom) "अन्य (लिखें)" else existing.designation,
                    customDesignation = if (isCustom) existing.designation else "",
                    gramPanchayat = existing.gramPanchayat,
                    vikasKhandBlock = existing.vikasKhandBlock,
                    district = existing.district,
                    slogan = existing.slogan,
                    phoneNumber = existing.phoneNumber,
                    selectedPartySymbol = existing.partySymbolPath ?: ProfileUiState.BUNDLED_PARTY_SYMBOLS.first(),
                    primaryColorHex = existing.primaryColorHex
                )
            } else {
                _uiState.value = ProfileUiState.Content()
            }
        }
    }

    fun onIntent(intent: ProfileIntent) {
        val current = _uiState.value as? ProfileUiState.Content ?: return

        when (intent) {
            is ProfileIntent.NameChanged -> {
                val error = if (intent.name.isBlank()) "कृपया प्रत्याशी का नाम दर्ज करें" else null
                _uiState.value = current.copy(candidateName = intent.name, nameErrorHindi = error)
            }
            is ProfileIntent.DesignationChanged -> {
                _uiState.value = current.copy(designation = intent.designation)
            }
            is ProfileIntent.CustomDesignationChanged -> {
                _uiState.value = current.copy(customDesignation = intent.custom)
            }
            is ProfileIntent.GramPanchayatChanged -> {
                val error = if (intent.panchayat.isBlank()) "कृपया ग्राम पंचायत का नाम दर्ज करें" else null
                _uiState.value = current.copy(gramPanchayat = intent.panchayat, panchayatErrorHindi = error)
            }
            is ProfileIntent.BlockChanged -> {
                _uiState.value = current.copy(vikasKhandBlock = intent.block)
            }
            is ProfileIntent.DistrictChanged -> {
                _uiState.value = current.copy(district = intent.district)
            }
            is ProfileIntent.SloganChanged -> {
                _uiState.value = current.copy(slogan = intent.slogan)
            }
            is ProfileIntent.PhoneChanged -> {
                _uiState.value = current.copy(phoneNumber = intent.phone)
            }
            is ProfileIntent.PhotoSelected -> {
                _uiState.value = current.copy(
                    rawPhotoBitmap = intent.bitmap,
                    cutoutPhotoBitmap = null,
                    removeBackgroundEnabled = false
                )
            }
            is ProfileIntent.ToggleRemoveBackground -> {
                _uiState.value = current.copy(removeBackgroundEnabled = intent.enabled)
                if (intent.enabled && current.rawPhotoBitmap != null) {
                    processBackgroundRemoval(current.rawPhotoBitmap)
                }
            }
            is ProfileIntent.PartySymbolSelected -> {
                _uiState.value = current.copy(selectedPartySymbol = intent.symbol)
            }
            is ProfileIntent.PrimaryColorSelected -> {
                _uiState.value = current.copy(primaryColorHex = intent.colorHex)
            }
            is ProfileIntent.SaveProfile -> {
                saveProfile(current)
            }
        }
    }

    private fun processBackgroundRemoval(bitmap: Bitmap) {
        viewModelScope.launch {
            _uiState.update {
                if (it is ProfileUiState.Content) it.copy(isRemovingBackground = true) else it
            }
            try {
                val cutout = backgroundRemover.removeBackground(bitmap)
                _uiState.update {
                    if (it is ProfileUiState.Content) {
                        it.copy(cutoutPhotoBitmap = cutout, isRemovingBackground = false)
                    } else it
                }
            } catch (e: Exception) {
                _uiState.update {
                    if (it is ProfileUiState.Content) {
                        it.copy(isRemovingBackground = false, removeBackgroundEnabled = false)
                    } else it
                }
            }
        }
    }

    private fun saveProfile(content: ProfileUiState.Content) {
        if (!content.isSaveEnabled) return

        viewModelScope.launch {
            _uiState.value = content.copy(isSaving = true)

            val effectiveDesignation = if (content.designation == "अन्य (लिखें)") {
                content.customDesignation.ifBlank { "ग्राम प्रतिनिधि" }
            } else {
                content.designation
            }

            val profile = CandidateProfile(
                candidateName = content.candidateName.trim(),
                designation = effectiveDesignation.trim(),
                gramPanchayat = content.gramPanchayat.trim(),
                vikasKhandBlock = content.vikasKhandBlock.trim(),
                district = content.district.trim(),
                slogan = content.slogan.trim(),
                candidatePhotoPath = null, // In production, persisted to filesDir/cutouts/
                partySymbolPath = content.selectedPartySymbol,
                primaryColorHex = content.primaryColorHex,
                phoneNumber = content.phoneNumber.trim(),
                updatedAt = System.currentTimeMillis()
            )

            candidateProfileDao.insertOrUpdate(profile)
            _uiState.value = content.copy(isSaving = false, isSaveSuccess = true)
        }
    }
}
