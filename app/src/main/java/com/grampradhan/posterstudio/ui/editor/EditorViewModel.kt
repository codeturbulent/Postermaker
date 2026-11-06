package com.grampradhan.posterstudio.ui.editor

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.grampradhan.posterstudio.core.data.db.DraftDao
import com.grampradhan.posterstudio.core.data.model.LayerSnapshot
import com.grampradhan.posterstudio.core.data.model.PosterDraft
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class EditorUiState(
    val layers: List<EditorLayer> = emptyList(),
    val selectedLayerId: String? = null,
    val inlineEditingTextId: String? = null,
    val canUndo: Boolean = false,
    val canRedo: Boolean = false,
    val isTypographySheetVisible: Boolean = false,
    val isLayersPanelVisible: Boolean = false,
    val isExporting: Boolean = false,
    val exportProgressMessage: String = "",
    val savedDraftId: Long? = null
)

@HiltViewModel
class EditorViewModel @Inject constructor(
    private val draftDao: DraftDao
) : ViewModel() {

    private val _uiState = MutableStateFlow(EditorUiState())
    val uiState: StateFlow<EditorUiState> = _uiState.asStateFlow()

    private val undoStack = ArrayDeque<List<EditorLayer>>(30)
    private val redoStack = ArrayDeque<List<EditorLayer>>(30)

    init {
        initializeDefaultCanvas()
    }

    private fun initializeDefaultCanvas() {
        val initialLayers = listOf(
            EditorLayer.BackgroundLayer(
                color = android.graphics.Color.parseColor("#FF5722")
            ),
            EditorLayer.TextLayer(
                id = "txt_slogan",
                name = "स्लोगन",
                zIndex = 1,
                translationX = 0f,
                translationY = -350f,
                text = "सबका साथ, गाँव का विकास",
                fontSizeSp = 32f,
                fontName = "Rozha One"
            ),
            EditorLayer.TextLayer(
                id = "txt_candidate_name",
                name = "प्रत्याशी नाम",
                zIndex = 2,
                translationX = 0f,
                translationY = 320f,
                text = "श्री राम सिंह यादव",
                fontSizeSp = 40f,
                fontName = "Baloo Bhai 2"
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
