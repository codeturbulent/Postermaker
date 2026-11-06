package com.grampradhan.posterstudio.ui.editor

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Redo
import androidx.compose.material.icons.automirrored.filled.Undo
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.FormatColorText
import androidx.compose.material.icons.filled.Layers
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.grampradhan.posterstudio.R
import kotlin.math.roundToInt

@Composable
fun EditorScreen(
    viewModel: EditorViewModel,
    onNavigateToExport: () -> Unit,
    modifier: Modifier = Modifier
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            EditorTopBar(
                canUndo = uiState.canUndo,
                canRedo = uiState.canRedo,
                onUndo = viewModel::undo,
                onRedo = viewModel::redo,
                onSaveDraft = viewModel::saveDraft,
                onExport = onNavigateToExport
            )
        },
        bottomBar = {
            EditorBottomControls(
                onOpenLayers = { viewModel.toggleLayersPanel(true) },
                onOpenTypography = { viewModel.toggleTypographySheet(true) },
                isTextSelected = uiState.layers.find { it.id == uiState.selectedLayerId } is EditorLayer.TextLayer
            )
        },
        modifier = modifier
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(Color(0xFF1E1E1E)),
            contentAlignment = Alignment.Center
        ) {
            PosterCanvasContainer(
                layers = uiState.layers,
                selectedLayerId = uiState.selectedLayerId,
                inlineEditingTextId = uiState.inlineEditingTextId,
                onSelectLayer = viewModel::selectLayer,
                onDoubleTapText = viewModel::startInlineEditing,
                onFinishInlineEditing = viewModel::finishInlineEditing,
                onTransformGesture = viewModel::onTransformGesture,
                onTransformEnd = viewModel::onTransformEnd
            )

            if (uiState.isExporting) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color.Black.copy(alpha = 0.65f)
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        CircularProgressIndicator(color = MaterialTheme.colorScheme.primary)
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = uiState.exportProgressMessage.ifEmpty { stringResource(R.string.export_status_rendering) },
                            color = Color.White,
                            style = MaterialTheme.typography.bodyLarge
                        )
                    }
                }
            }
        }

        // Bottom Sheets for Typography & Layer Management
        val selectedTextLayer = uiState.layers.find { it.id == uiState.selectedLayerId } as? EditorLayer.TextLayer
        if (uiState.isTypographySheetVisible && selectedTextLayer != null) {
            TypographyBottomSheet(
                layer = selectedTextLayer,
                onDismiss = { viewModel.toggleTypographySheet(false) },
                onUpdateLayer = { updated -> viewModel.updateActiveTextLayer { updated } }
            )
        }

        if (uiState.isLayersPanelVisible) {
            LayerPanelBottomSheet(
                layers = uiState.layers,
                selectedLayerId = uiState.selectedLayerId,
                onSelectLayer = viewModel::selectLayer,
                onBringForward = viewModel::bringForward,
                onSendBackward = viewModel::sendBackward,
                onToggleLock = viewModel::toggleLock,
                onFlipHorizontal = viewModel::flipHorizontal,
                onDelete = viewModel::deleteActiveLayer,
                onDismiss = { viewModel.toggleLayersPanel(false) }
            )
        }
    }
}

@Composable
private fun EditorTopBar(
    canUndo: Boolean,
    canRedo: Boolean,
    onUndo: () -> Unit,
    onRedo: () -> Unit,
    onSaveDraft: () -> Unit,
    onExport: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 4.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row {
                IconButton(
                    onClick = onUndo,
                    enabled = canUndo,
                    modifier = Modifier.size(48.dp)
                ) {
                    Icon(
                        Icons.AutoMirrored.Filled.Undo,
                        contentDescription = stringResource(R.string.btn_undo)
                    )
                }
                IconButton(
                    onClick = onRedo,
                    enabled = canRedo,
                    modifier = Modifier.size(48.dp)
                ) {
                    Icon(
                        Icons.AutoMirrored.Filled.Redo,
                        contentDescription = stringResource(R.string.btn_redo)
                    )
                }
            }

            Text(
                text = stringResource(R.string.editor_title),
                style = MaterialTheme.typography.titleMedium
            )

            Row {
                IconButton(
                    onClick = onSaveDraft,
                    modifier = Modifier.size(48.dp)
                ) {
                    Icon(
                        Icons.Default.Save,
                        contentDescription = stringResource(R.string.btn_save_draft)
                    )
                }
                IconButton(
                    onClick = onExport,
                    modifier = Modifier.size(48.dp)
                ) {
                    Icon(
                        Icons.Default.Download,
                        contentDescription = stringResource(R.string.btn_export),
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
            }
        }
    }
}

@Composable
private fun EditorBottomControls(
    onOpenLayers: () -> Unit,
    onOpenTypography: () -> Unit,
    isTextSelected: Boolean
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 8.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceAround,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = onOpenLayers,
                modifier = Modifier.size(48.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(Icons.Default.Layers, contentDescription = stringResource(R.string.layers_panel))
                }
            }

            if (isTextSelected) {
                IconButton(
                    onClick = onOpenTypography,
                    modifier = Modifier.size(48.dp)
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            Icons.Default.FormatColorText,
                            contentDescription = stringResource(R.string.typography_settings),
                            tint = MaterialTheme.colorScheme.primary
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun PosterCanvasContainer(
    layers: List<EditorLayer>,
    selectedLayerId: String?,
    inlineEditingTextId: String?,
    onSelectLayer: (String?) -> Unit,
    onDoubleTapText: (String) -> Unit,
    onFinishInlineEditing: (String) -> Unit,
    onTransformGesture: (Float, Float, Float, Float) -> Unit,
    onTransformEnd: () -> Unit
) {
    BoxWithConstraints(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        contentAlignment = Alignment.Center
    ) {
        val canvasSize = minOf(maxWidth, maxHeight)

        Box(
            modifier = Modifier
                .size(canvasSize)
                .aspectRatio(1f) // Square default 1:1 for social / flex
                .shadow(12.dp, RoundedCornerShape(4.dp))
                .clip(RoundedCornerShape(4.dp))
                .background(Color.White)
                .pointerInput(Unit) {
                    detectTapGestures(
                        onTap = { onSelectLayer(null) }
                    )
                }
        ) {
            // Background is drawn first and isolated to prevent recomposition during active transformations
            val bgLayer = layers.find { it is EditorLayer.BackgroundLayer } as? EditorLayer.BackgroundLayer
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(bgLayer?.let { Color(it.color) } ?: Color.White)
            )

            // Render interactive layers sorted by zIndex
            val interactiveLayers = layers.filterNot { it is EditorLayer.BackgroundLayer }.sortedBy { it.zIndex }
            interactiveLayers.forEach { layer ->
                val isSelected = layer.id == selectedLayerId
                val isInlineEditing = layer.id == inlineEditingTextId

                CanvasLayerItem(
                    layer = layer,
                    isSelected = isSelected,
                    isInlineEditing = isInlineEditing,
                    onSelect = { onSelectLayer(layer.id) },
                    onDoubleTap = { onDoubleTapText(layer.id) },
                    onFinishInlineEditing = onFinishInlineEditing,
                    onTransformGesture = onTransformGesture,
                    onTransformEnd = onTransformEnd
                )
            }
        }
    }
}

@Composable
private fun CanvasLayerItem(
    layer: EditorLayer,
    isSelected: Boolean,
    isInlineEditing: Boolean,
    onSelect: () -> Unit,
    onDoubleTap: () -> Unit,
    onFinishInlineEditing: (String) -> Unit,
    onTransformGesture: (Float, Float, Float, Float) -> Unit,
    onTransformEnd: () -> Unit
) {
    val gestureModifier = if (isSelected && !layer.isLocked) {
        Modifier.pointerInput(layer.id) {
            detectTransformGestures { _, pan, zoom, rotation ->
                onTransformGesture(pan.x, pan.y, zoom, rotation)
            }
        }
    } else Modifier

    Box(
        modifier = Modifier
            .offset { IntOffset(layer.translationX.roundToInt(), layer.translationY.roundToInt()) }
            .graphicsLayer {
                scaleX = layer.scale * (if (layer.isFlippedHorizontal) -1f else 1f)
                scaleY = layer.scale
                rotationZ = layer.rotation
            }
            .then(gestureModifier)
            .pointerInput(layer.id) {
                detectTapGestures(
                    onTap = { onSelect() },
                    onDoubleTap = { onDoubleTap() }
                )
            }
            .then(
                if (isSelected) {
                    Modifier.border(1.5.dp, MaterialTheme.colorScheme.primary, RoundedCornerShape(2.dp))
                } else Modifier
            )
            .padding(4.dp),
        contentAlignment = Alignment.Center
    ) {
        when (layer) {
            is EditorLayer.TextLayer -> {
                if (isInlineEditing) {
                    var textInput by remember { mutableStateOf(layer.text) }
                    BasicTextField(
                        value = textInput,
                        onValueChange = {
                            textInput = it
                            onFinishInlineEditing(it)
                        },
                        textStyle = TextStyle(
                            color = Color(layer.textColor),
                            fontSize = layer.fontSizeSp.sp,
                            fontWeight = FontWeight.Bold
                        ),
                        modifier = Modifier.padding(2.dp)
                    )
                } else {
                    Text(
                        text = layer.text,
                        color = Color(layer.textColor),
                        fontSize = layer.fontSizeSp.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.semantics {
                            contentDescription = "पोस्टर टेक्स्ट: ${layer.text}"
                        }
                    )
                }
            }
            is EditorLayer.ImageLayer -> {
                Text(
                    text = "👤 [फ़ोटो]",
                    fontSize = 24.sp,
                    color = Color.DarkGray
                )
            }
            is EditorLayer.StickerLayer -> {
                Text(
                    text = "⭐ [चिन्ह]",
                    fontSize = 24.sp,
                    color = Color.DarkGray
                )
            }
            is EditorLayer.BackgroundLayer -> Unit
        }
    }
}
