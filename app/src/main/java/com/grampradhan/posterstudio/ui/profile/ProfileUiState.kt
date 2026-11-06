package com.grampradhan.posterstudio.ui.profile

import android.graphics.Bitmap
import com.grampradhan.posterstudio.core.data.model.CandidateProfile

sealed interface ProfileUiState {
    data object Loading : ProfileUiState

    data class Content(
        val candidateName: String = "",
        val designation: String = DESIGNATION_PRESETS.first(),
        val customDesignation: String = "",
        val gramPanchayat: String = "",
        val vikasKhandBlock: String = "",
        val district: String = "",
        val slogan: String = "सबका साथ, गाँव का सर्वांगीण विकास",
        val phoneNumber: String = "",
        val rawPhotoBitmap: Bitmap? = null,
        val cutoutPhotoBitmap: Bitmap? = null,
        val isRemovingBackground: Boolean = false,
        val removeBackgroundEnabled: Boolean = false,
        val selectedPartySymbol: String = BUNDLED_PARTY_SYMBOLS.first(),
        val primaryColorHex: String = "#FF6A1B",
        val nameErrorHindi: String? = null,
        val panchayatErrorHindi: String? = null,
        val isSaving: Boolean = false,
        val isSaveSuccess: Boolean = false
    ) : ProfileUiState {
        val isSaveEnabled: Boolean
            get() = candidateName.isNotBlank() &&
                    gramPanchayat.isNotBlank() &&
                    !isSaving &&
                    !isRemovingBackground
    }

    data class Error(val messageHindi: String) : ProfileUiState

    companion object {
        val DESIGNATION_PRESETS = listOf(
            "ग्राम प्रधान",
            "भावी ग्राम प्रधान प्रत्याशी",
            "निवर्तमान ग्राम प्रधान",
            "BDC सदस्य (क्षेत्र पंचायत)",
            "जिला पंचायत सदस्य",
            "जिला पंचायत अध्यक्ष प्रत्याशी",
            "उप-प्रधान",
            "ग्राम पंचायत सदस्य (वार्ड)",
            "सहकारी समिति अध्यक्ष",
            "मंडल अध्यक्ष",
            "समाजसेवी / युवा नेता",
            "अन्य (लिखें)"
        )

        val BUNDLED_PARTY_SYMBOLS = listOf(
            "ट्रैक्टर", "हैंडपंप", "घड़ी", "कार", "सूरजमुखी", "हाथी",
            "साइकिल", "कमल", "तीर-धनुष", "लालटेन", "झाड़ू", "पंखा",
            "हलधर किसान", "गदा", "पतंग", "कप-प्लेट", "गिलास", "बल्ला",
            "मोमबत्ती", "अंगूठी"
        )
    }
}
