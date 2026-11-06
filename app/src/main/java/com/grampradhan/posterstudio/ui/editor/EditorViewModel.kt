package com.grampradhan.posterstudio.ui.editor

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grampradhan.posterstudio.core.data.db.CandidateProfileDao
import com.grampradhan.posterstudio.core.data.db.DraftDao
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
import com.grampradhan.posterstudio.core.data.model.LayerSnapshot
import com.grampradhan.posterstudio.core.data.model.PosterDraft
import com.grampradhan.posterstudio.core.data.model.SlotType
import com.grampradhan.posterstudio.core.data.repository.ImageSearchResult
import com.grampradhan.posterstudio.core.data.repository.ImageSearchService
import com.grampradhan.posterstudio.core.data.repository.TemplateRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.util.UUID
import javax.inject.Inject

val AVAILABLE_RIBBON_COLORS = listOf(
    0xFFD84315.toInt(), // Deep Kesariya / Saffron
    0xFF1B5E20.toInt(), // Bharat / Forest Green
    0xFFC62828.toInt(), // Kranti / Samajwadi Red
    0xFF0D47A1.toInt(), // Deep Navy Blue
    0xFF4A148C.toInt(), // Royal Purple
    0xFF3E2723.toInt(), // Deep Maroon
    0xFF212121.toInt()  // Slate Black
)

val STICKER_BADGES = listOf(
    "🪔", // Diya
    "🕉️", // Om
    "🌾", // Kisan / Wheat
    "🤝", // Namaste / Appeal
    "🇮🇳", // Tiranga
    "🗳️", // Vote / Ballot
    "🚩", // Dhwaja
    "🌺", // Kamal / Lotus
    "✨", // Star
    "🎉"  // Celebration
)

data class EditorUiState(
    val templateId: String = "default",
    val layers: List<EditorLayer> = emptyList(),
    val selectedLayerId: String? = null,
    val inlineEditingTextId: String? = null,
    val canUndo: Boolean = false,
    val canRedo: Boolean = false,
    val isTypographySheetVisible: Boolean = false,
    val isLayersPanelVisible: Boolean = false,
    val isSloganPickerVisible: Boolean = false,
    val isImageSearchVisible: Boolean = false,
    val aspectRatio: Float = 1.0f, // 1:1 = 1.0f, 4:5 = 0.8f, 9:16 = 0.5625f
    val ribbonColor: Int = 0xFFD84315.toInt(),
    val photoAlignmentLeft: Boolean = true,
    val candidateProfile: CandidateProfile? = null,
    val isExporting: Boolean = false,
    val exportProgressMessage: String = "",
    val savedDraftId: Long? = null
)

@HiltViewModel
class EditorViewModel @Inject constructor(
    private val draftDao: DraftDao,
    private val templateRepository: TemplateRepository,
    private val candidateProfileDao: CandidateProfileDao,
    val imageSearchService: ImageSearchService
) : ViewModel() {

    private val _uiState = MutableStateFlow(EditorUiState())
    val uiState: StateFlow<EditorUiState> = _uiState.asStateFlow()

    private val undoStack = ArrayDeque<List<EditorLayer>>(30)
    private val redoStack = ArrayDeque<List<EditorLayer>>(30)

    init {
        initializeDefaultCanvas()
    }

    fun loadTemplate(templateId: String) {
        viewModelScope.launch {
            val template = templateRepository.getTemplateById(templateId) ?: return@launch
            val profile = candidateProfileDao.getActiveProfile()

            val newLayers = mutableListOf<EditorLayer>()

            // 1. Background layer
            val bgLayer = if (template.backgroundUrl.startsWith("gradient:")) {
                val hexColors = template.backgroundUrl.removePrefix("gradient:").split(":")
                val parsedColor = runCatching { android.graphics.Color.parseColor(hexColors.first()) }.getOrDefault(0xFFFFFFFF.toInt())
                EditorLayer.BackgroundLayer(color = parsedColor, backgroundUrl = template.backgroundUrl)
            } else if (template.backgroundUrl.isNotEmpty()) {
                EditorLayer.BackgroundLayer(backgroundUrl = template.backgroundUrl)
            } else {
                EditorLayer.BackgroundLayer(color = 0xFFFFFFFF.toInt())
            }
            newLayers.add(bgLayer)

            var zCounter = 1

            // 2. Predefined template text layers
            template.predefinedTextLayers.forEach { textConfig ->
                newLayers.add(
                    EditorLayer.TextLayer(
                        id = textConfig.layerId,
                        name = "हेडलाइन",
                        zIndex = zCounter++,
                        translationX = 0f,
                        translationY = (textConfig.yRatio - 0.5f) * 600f,
                        text = textConfig.text,
                        fontSizeSp = textConfig.fontSizeSp,
                        fontName = textConfig.fontName,
                        textColor = runCatching { android.graphics.Color.parseColor(textConfig.colorHex) }.getOrDefault(0xFFFFFFFF.toInt()),
                        strokeWidthDp = textConfig.strokeWidthDp
                    )
                )
            }

            // 3. Auto-bind brand kit fields into template slots
            if (profile != null) {
                template.slotConfigs.forEach { slot ->
                    when (slot.slotType) {
                        SlotType.CANDIDATE_PHOTO -> {
                            newLayers.add(
                                EditorLayer.ImageLayer(
                                    id = "slot_candidate_photo",
                                    name = "प्रत्याशी फ़ोटो",
                                    zIndex = zCounter++,
                                    translationX = (slot.xRatio - 0.5f) * 500f,
                                    translationY = (slot.yRatio - 0.5f) * 500f,
                                    scale = 1.0f,
                                    imagePath = profile.candidatePhotoPath
                                )
                            )
                        }
                        SlotType.PARTY_SYMBOL -> {
                            newLayers.add(
                                EditorLayer.StickerLayer(
                                    id = "slot_party_symbol",
                                    name = "चुनाव चिन्ह: ${profile.partySymbolPath ?: "चिन्ह"}",
                                    zIndex = zCounter++,
                                    translationX = (slot.xRatio - 0.5f) * 500f,
                                    translationY = (slot.yRatio - 0.5f) * 500f,
                                    scale = 1.0f,
                                    symbolKey = profile.partySymbolPath
                                )
                            )
                        }
                        SlotType.VILLAGE_TEXT -> {
                            newLayers.add(
                                EditorLayer.TextLayer(
                                    id = "slot_candidate_name",
                                    name = "प्रत्याशी नामपट्टी",
                                    zIndex = zCounter++,
                                    translationX = 0f,
                                    translationY = (slot.yRatio - 0.5f) * 600f,
                                    text = "${profile.candidateName} (${profile.designation})",
                                    fontSizeSp = 22f,
                                    textColor = 0xFFFFFF00.toInt(),
                                    strokeColor = 0xFF000000.toInt(),
                                    strokeWidthDp = 2f
                                )
                            )
                        }
                        else -> Unit
                    }
                }
            }

            val templateAspect = template.aspectRatio.widthRatio / template.aspectRatio.heightRatio

            undoStack.clear()
            redoStack.clear()
            _uiState.update {
                it.copy(
                    templateId = templateId,
                    layers = newLayers,
                    selectedLayerId = newLayers.lastOrNull { l -> l !is EditorLayer.BackgroundLayer }?.id,
                    candidateProfile = profile,
                    aspectRatio = templateAspect,
                    canUndo = false,
                    canRedo = false
                )
            }
        }
    }

    private fun initializeDefaultCanvas() {
        val initialLayers = listOf(
            EditorLayer.BackgroundLayer(
                color = 0xFFFF5722.toInt()
            ),
            EditorLayer.TextLayer(
                id = "txt_slogan",
                name = "स्लोगन",
                zIndex = 1,
                translationX = 0f,
                translationY = -280f,
                text = "सबका साथ, गाँव का संपूर्ण विकास",
                fontSizeSp = 28f,
                fontName = "Rozha One"
            ),
            EditorLayer.TextLayer(
                id = "txt_candidate_name",
                name = "प्रत्याशी नाम",
                zIndex = 2,
                translationX = 0f,
                translationY = 280f,
                text = "राजेश कुमार यादव (ग्राम प्रधान)",
                fontSizeSp = 32f,
                fontName = "Baloo Bhai 2",
                textColor = 0xFFFFFF00.toInt(),
                strokeColor = 0xFF000000.toInt(),
                strokeWidthDp = 2.5f
            )
        )
        _uiState.update { it.copy(layers = initialLayers, selectedLayerId = "txt_candidate_name") }
    }

    fun selectLayer(layerId: String?) {
        _uiState.update { it.copy(selectedLayerId = layerId, inlineEditingTextId = null) }
    }

    fun startInlineEditing(layerId: String) {
        val layer = _uiState.value.layers.find { it.id == layerId }
        if (layer is EditorLayer.TextLayer && !layer.isLocked) {
            _uiState.update { it.copy(selectedLayerId = layerId, inlineEditingTextId = layerId) }
        }
    }

    fun finishInlineEditing(newText: String) {
        val currentId = _uiState.value.inlineEditingTextId ?: return
        pushUndoSnapshot()
        _uiState.update { state ->
            val updated = state.layers.map { layer ->
                if (layer.id == currentId && layer is EditorLayer.TextLayer) {
                    layer.copy(text = newText)
                } else layer
            }
            state.copy(layers = updated, inlineEditingTextId = null)
        }
    }

    fun onTransformGesture(panX: Float, panY: Float, zoomFactor: Float, rotationDelta: Float) {
        val activeId = _uiState.value.selectedLayerId ?: return
        _uiState.update { state ->
            val updatedLayers = state.layers.map { layer ->
                if (layer.id == activeId && !layer.isLocked) {
                    val newScale = (layer.scale * zoomFactor).coerceIn(0.2f, 5.0f)
                    val newRotation = (layer.rotation + rotationDelta) % 360f
                    val newX = layer.translationX + panX
                    val newY = layer.translationY + panY
                    layer.copyWithTransform(
                        translationX = newX,
                        translationY = newY,
                        scale = newScale,
                        rotation = newRotation
                    )
                } else layer
            }
            state.copy(layers = updatedLayers)
        }
    }

    fun onTransformEnd() {
        pushUndoSnapshot()
    }

    fun updateActiveTextLayer(transform: (EditorLayer.TextLayer) -> EditorLayer.TextLayer) {
        val activeId = _uiState.value.selectedLayerId ?: return
        pushUndoSnapshot()
        _uiState.update { state ->
            val updated = state.layers.map { layer ->
                if (layer.id == activeId && layer is EditorLayer.TextLayer && !layer.isLocked) {
                    transform(layer)
                } else layer
            }
            state.copy(layers = updated)
        }
    }

    fun bringForward() {
        val activeId = _uiState.value.selectedLayerId ?: return
        pushUndoSnapshot()
        _uiState.update { state ->
            val sorted = state.layers.sortedBy { it.zIndex }.toMutableList()
            val index = sorted.indexOfFirst { it.id == activeId }
            if (index in 0 until sorted.size - 1) {
                val current = sorted[index]
                val next = sorted[index + 1]
                val currentZ = current.zIndex
                sorted[index] = current.copyWithTransform(zIndex = next.zIndex)
                sorted[index + 1] = next.copyWithTransform(zIndex = currentZ)
            }
            state.copy(layers = sorted)
        }
    }

    fun sendBackward() {
        val activeId = _uiState.value.selectedLayerId ?: return
        pushUndoSnapshot()
        _uiState.update { state ->
            val sorted = state.layers.sortedBy { it.zIndex }.toMutableList()
            val index = sorted.indexOfFirst { it.id == activeId }
            if (index > 1) { // 0 is reserved for background
                val current = sorted[index]
                val prev = sorted[index - 1]
                val currentZ = current.zIndex
                sorted[index] = current.copyWithTransform(zIndex = prev.zIndex)
                sorted[index - 1] = prev.copyWithTransform(zIndex = currentZ)
            }
            state.copy(layers = sorted)
        }
    }

    fun toggleLock() {
        val activeId = _uiState.value.selectedLayerId ?: return
        pushUndoSnapshot()
        _uiState.update { state ->
            val updated = state.layers.map { layer ->
                if (layer.id == activeId) {
                    layer.copyWithTransform(isLocked = !layer.isLocked)
                } else layer
            }
            state.copy(layers = updated)
        }
    }

    fun flipHorizontal() {
        val activeId = _uiState.value.selectedLayerId ?: return
        pushUndoSnapshot()
        _uiState.update { state ->
            val updated = state.layers.map { layer ->
                if (layer.id == activeId && !layer.isLocked) {
                    layer.copyWithTransform(isFlippedHorizontal = !layer.isFlippedHorizontal)
                } else layer
            }
            state.copy(layers = updated)
        }
    }

    fun deleteActiveLayer() {
        val activeId = _uiState.value.selectedLayerId ?: return
        val layer = _uiState.value.layers.find { it.id == activeId }
        if (layer is EditorLayer.BackgroundLayer) return // Cannot delete background
        pushUndoSnapshot()
        _uiState.update { state ->
            val updated = state.layers.filterNot { it.id == activeId }
            state.copy(layers = updated, selectedLayerId = null)
        }
    }

    fun undo() {
        if (undoStack.isEmpty()) return
        val currentSnapshot = _uiState.value.layers
        if (redoStack.size >= 30) redoStack.removeFirst()
        redoStack.addLast(currentSnapshot)

        val previous = undoStack.removeLast()
        _uiState.update {
            it.copy(
                layers = previous,
                canUndo = undoStack.isNotEmpty(),
                canRedo = true
            )
        }
    }

    fun redo() {
        if (redoStack.isEmpty()) return
        val currentSnapshot = _uiState.value.layers
        if (undoStack.size >= 30) undoStack.removeFirst()
        undoStack.addLast(currentSnapshot)

        val next = redoStack.removeLast()
        _uiState.update {
            it.copy(
                layers = next,
                canUndo = true,
                canRedo = redoStack.isNotEmpty()
            )
        }
    }

    private fun pushUndoSnapshot() {
        val current = _uiState.value.layers
        if (undoStack.size >= 30) undoStack.removeFirst()
        undoStack.addLast(current)
        redoStack.clear()
        _uiState.update { it.copy(canUndo = true, canRedo = false) }
    }

    fun toggleTypographySheet(visible: Boolean) {
        _uiState.update { it.copy(isTypographySheetVisible = visible) }
    }

    fun toggleLayersPanel(visible: Boolean) {
        _uiState.update { it.copy(isLayersPanelVisible = visible) }
    }

    fun toggleSloganPicker(visible: Boolean) {
        _uiState.update { it.copy(isSloganPickerVisible = visible) }
    }

    fun toggleImageSearch(visible: Boolean) {
        _uiState.update { it.copy(isImageSearchVisible = visible) }
    }

    fun setAspectRatio(ratio: Float) {
        _uiState.update { it.copy(aspectRatio = ratio) }
    }

    fun setRibbonColor(color: Int) {
        _uiState.update { it.copy(ribbonColor = color) }
    }

    fun togglePhotoAlignment() {
        pushUndoSnapshot()
        val newAlignmentLeft = !_uiState.value.photoAlignmentLeft
        _uiState.update { state ->
            val updatedLayers = state.layers.map { layer ->
                if (layer.id == "slot_candidate_photo" || layer.name.contains("फ़ोटो")) {
                    val targetX = if (newAlignmentLeft) -160f else 160f
                    layer.copyWithTransform(translationX = targetX)
                } else if (layer.id == "slot_party_symbol" || layer.name.contains("चिन्ह")) {
                    val targetX = if (newAlignmentLeft) 160f else -160f
                    layer.copyWithTransform(translationX = targetX)
                } else layer
            }
            state.copy(photoAlignmentLeft = newAlignmentLeft, layers = updatedLayers)
        }
    }

    fun applySlogan(sloganText: String) {
        pushUndoSnapshot()
        _uiState.update { state ->
            val activeId = state.selectedLayerId
            val activeLayer = state.layers.find { it.id == activeId }

            if (activeLayer is EditorLayer.TextLayer) {
                val updated = state.layers.map {
                    if (it.id == activeId) (it as EditorLayer.TextLayer).copy(text = sloganText) else it
                }
                state.copy(layers = updated, isSloganPickerVisible = false)
            } else {
                // Find headline or slogan layer or create a new text layer
                val existingSloganLayer = state.layers.find {
                    it is EditorLayer.TextLayer && (it.id.contains("slogan") || it.name.contains("स्लोगन") || it.name.contains("हेडलाइन"))
                }
                if (existingSloganLayer != null) {
                    val updated = state.layers.map {
                        if (it.id == existingSloganLayer.id) (it as EditorLayer.TextLayer).copy(text = sloganText) else it
                    }
                    state.copy(layers = updated, selectedLayerId = existingSloganLayer.id, isSloganPickerVisible = false)
                } else {
                    val nextZ = (state.layers.maxOfOrNull { it.zIndex } ?: 0) + 1
                    val newLayer = EditorLayer.TextLayer(
                        id = UUID.randomUUID().toString(),
                        name = "स्लोगन",
                        zIndex = nextZ,
                        translationX = 0f,
                        translationY = -180f,
                        text = sloganText,
                        fontSizeSp = 26f,
                        fontName = "Rozha One",
                        textColor = 0xFFFFFFFF.toInt(),
                        strokeColor = 0xFF000000.toInt(),
                        strokeWidthDp = 2f
                    )
                    state.copy(
                        layers = state.layers + newLayer,
                        selectedLayerId = newLayer.id,
                        isSloganPickerVisible = false
                    )
                }
            }
        }
    }

    fun addNewText(text: String = "हार्दिक शुभकामनाएं") {
        pushUndoSnapshot()
        val nextZ = (_uiState.value.layers.maxOfOrNull { it.zIndex } ?: 0) + 1
        val newLayer = EditorLayer.TextLayer(
            id = UUID.randomUUID().toString(),
            name = "टेक्स्ट",
            zIndex = nextZ,
            translationX = 0f,
            translationY = 0f,
            text = text,
            fontSizeSp = 28f,
            fontName = "Rozha One",
            textColor = 0xFFFFFF00.toInt(),
            strokeColor = 0xFF000000.toInt(),
            strokeWidthDp = 2f
        )
        _uiState.update {
            it.copy(
                layers = it.layers + newLayer,
                selectedLayerId = newLayer.id
            )
        }
    }

    fun addStickerBadge(emoji: String) {
        pushUndoSnapshot()
        val nextZ = (_uiState.value.layers.maxOfOrNull { it.zIndex } ?: 0) + 1
        val newLayer = EditorLayer.StickerLayer(
            id = UUID.randomUUID().toString(),
            name = "स्टीकर $emoji",
            zIndex = nextZ,
            translationX = 140f,
            translationY = -220f,
            scale = 1.0f,
            symbolKey = emoji
        )
        _uiState.update {
            it.copy(
                layers = it.layers + newLayer,
                selectedLayerId = newLayer.id
            )
        }
    }

    fun addImageFromSearch(result: ImageSearchResult, asBackground: Boolean = false) {
        pushUndoSnapshot()
        _uiState.update { state ->
            if (asBackground) {
                val updated = state.layers.map { layer ->
                    if (layer is EditorLayer.BackgroundLayer) {
                        layer.copy(backgroundUrl = result.fullUrl, color = 0xFFFFFFFF.toInt())
                    } else layer
                }
                state.copy(layers = updated, isImageSearchVisible = false)
            } else {
                val nextZ = (state.layers.maxOfOrNull { it.zIndex } ?: 0) + 1
                val newLayer = EditorLayer.ImageLayer(
                    id = UUID.randomUUID().toString(),
                    name = result.title.take(15),
                    zIndex = nextZ,
                    translationX = 0f,
                    translationY = 0f,
                    scale = 1.0f,
                    imageUrl = result.fullUrl
                )
                state.copy(
                    layers = state.layers + newLayer,
                    selectedLayerId = newLayer.id,
                    isImageSearchVisible = false
                )
            }
        }
    }

    fun saveDraft(templateId: String = "custom_draft") {
        viewModelScope.launch {
            val snapshots = _uiState.value.layers.map { layer ->
                LayerSnapshot(
                    layerId = layer.id,
                    type = when (layer) {
                        is EditorLayer.TextLayer -> "TEXT"
                        is EditorLayer.ImageLayer -> "IMAGE"
                        is EditorLayer.StickerLayer -> "STICKER"
                        is EditorLayer.BackgroundLayer -> "BACKGROUND"
                    },
                    zIndex = layer.zIndex,
                    translationX = layer.translationX,
                    translationY = layer.translationY,
                    scale = layer.scale,
                    rotation = layer.rotation,
                    isLocked = layer.isLocked,
                    textContent = (layer as? EditorLayer.TextLayer)?.text,
                    fontName = (layer as? EditorLayer.TextLayer)?.fontName,
                    fontSizeSp = (layer as? EditorLayer.TextLayer)?.fontSizeSp,
                    strokeWidthDp = (layer as? EditorLayer.TextLayer)?.strokeWidthDp,
                    curveArc = (layer as? EditorLayer.TextLayer)?.curvedArc
                )
            }
            val draft = PosterDraft(
                templateId = templateId,
                layers = snapshots,
                previewPath = ""
            )
            val id = draftDao.insertDraft(draft)
            _uiState.update { it.copy(savedDraftId = id) }
        }
    }
}
