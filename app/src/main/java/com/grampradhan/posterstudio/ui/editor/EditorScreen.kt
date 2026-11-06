package com.grampradhan.posterstudio.ui.editor

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Redo
import androidx.compose.material.icons.automirrored.filled.Undo
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CropPortrait
import androidx.compose.material.icons.filled.CropSquare
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.FormatColorText
import androidx.compose.material.icons.filled.FormatQuote
import androidx.compose.material.icons.filled.ImageSearch
import androidx.compose.material.icons.filled.Layers
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.StayCurrentPortrait
import androidx.compose.material.icons.filled.SwapHoriz
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ElevatedAssistChip
import androidx.compose.material3.FilterChip
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
import com.grampradhan.posterstudio.R
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
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
            EditorBottomStudioControls(
                ribbonColor = uiState.ribbonColor,
                onSelectRibbonColor = viewModel::setRibbonColor,
                onAddBadge = viewModel::addStickerBadge,
                onOpenLayers = { viewModel.toggleLayersPanel(true) },
                onOpenTypography = { viewModel.toggleTypographySheet(true) },
                isTextSelected = uiState.layers.find { it.id == uiState.selectedLayerId } is EditorLayer.TextLayer
            )
        },
        modifier = modifier
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(Color(0xFF1E1E1E)),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Quick Studio Action Bar (Aspect Ratio, Slogan Bank, Stock Images, Add Text, Photo Alignment)
            QuickStudioActionBar(
                currentAspectRatio = uiState.aspectRatio,
                onSelectAspectRatio = viewModel::setAspectRatio,
                onOpenSloganPicker = { viewModel.toggleSloganPicker(true) },
                onOpenImageSearch = { viewModel.toggleImageSearch(true) },
                onAddNewText = { viewModel.addNewText() },
                onTogglePhotoAlignment = viewModel::togglePhotoAlignment
            )

            // Live Interactive Canvas Area
            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                PosterCanvasContainer(
                    layers = uiState.layers,
                    aspectRatio = uiState.aspectRatio,
                    ribbonColor = uiState.ribbonColor,
                    candidateProfile = uiState.candidateProfile,
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
        }

        // Bottom Sheets for Typography, Layers, Slogan Bank, Image Search
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

        if (uiState.isSloganPickerVisible) {
            SloganPickerBottomSheet(
                onDismiss = { viewModel.toggleSloganPicker(false) },
                onSelectSlogan = { slogan ->
                    viewModel.applySlogan(slogan)
                }
            )
        }

        if (uiState.isImageSearchVisible) {
            ImageSearchBottomSheet(
                imageSearchService = viewModel.imageSearchService,
                onDismiss = { viewModel.toggleImageSearch(false) },
                onSelectImage = { result ->
                    viewModel.addImageFromSearch(result)
                }
            )
        }
    }
}

@Composable
private fun QuickStudioActionBar(
    currentAspectRatio: Float,
    onSelectAspectRatio: (Float) -> Unit,
    onOpenSloganPicker: () -> Unit,
    onOpenImageSearch: () -> Unit,
    onAddNewText: () -> Unit,
    onTogglePhotoAlignment: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = Color(0xFF282828),
        shadowElevation = 2.dp
    ) {
        Column(modifier = Modifier.padding(vertical = 4.dp, horizontal = 8.dp)) {
            // Row 1: Aspect Ratio Selectors
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    FilterChip(
                        selected = kotlin.math.abs(currentAspectRatio - 1.0f) < 0.05f,
                        onClick = { onSelectAspectRatio(1.0f) },
                        label = { Text("1:1 पोस्ट", fontSize = 11.sp) },
                        leadingIcon = { Icon(Icons.Default.CropSquare, contentDescription = null, modifier = Modifier.size(14.dp)) }
                    )
                    FilterChip(
                        selected = kotlin.math.abs(currentAspectRatio - 0.8f) < 0.05f,
                        onClick = { onSelectAspectRatio(0.8f) },
                        label = { Text("4:5 बैनर", fontSize = 11.sp) },
                        leadingIcon = { Icon(Icons.Default.CropPortrait, contentDescription = null, modifier = Modifier.size(14.dp)) }
                    )
                    FilterChip(
                        selected = kotlin.math.abs(currentAspectRatio - (9f / 16f)) < 0.05f,
                        onClick = { onSelectAspectRatio(9f / 16f) },
                        label = { Text("9:16 स्टेटस", fontSize = 11.sp) },
                        leadingIcon = { Icon(Icons.Default.StayCurrentPortrait, contentDescription = null, modifier = Modifier.size(14.dp)) }
                    )
                }
            }

            // Row 2: Studio Tool Quick Action Chips
            LazyRow(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 4.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                item {
                    ElevatedAssistChip(
                        onClick = onOpenSloganPicker,
                        label = { Text("📝 सुझाव बैंक", fontSize = 12.sp, fontWeight = FontWeight.SemiBold) }
                    )
                }
                item {
                    ElevatedAssistChip(
                        onClick = onOpenImageSearch,
                        label = { Text("🖼️ इमेज खोजें", fontSize = 12.sp, fontWeight = FontWeight.SemiBold) }
                    )
                }
                item {
                    ElevatedAssistChip(
                        onClick = onAddNewText,
                        label = { Text("✨ + टेक्स्ट", fontSize = 12.sp, fontWeight = FontWeight.SemiBold) }
                    )
                }
                item {
                    ElevatedAssistChip(
                        onClick = onTogglePhotoAlignment,
                        label = { Text("↔️ फ़ोटो स्थिति", fontSize = 12.sp, fontWeight = FontWeight.SemiBold) }
                    )
                }
            }
        }
    }
}

@Composable
private fun EditorBottomStudioControls(
    ribbonColor: Int,
    onSelectRibbonColor: (Int) -> Unit,
    onAddBadge: (String) -> Unit,
    onOpenLayers: () -> Unit,
    onOpenTypography: () -> Unit,
    isTextSelected: Boolean
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 8.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp, horizontal = 12.dp)
        ) {
            // 1. Ribbon Color Palette Quick Swatches
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "नेमप्लेट रिबन:",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(end = 6.dp)
                )

                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.weight(1f)
                ) {
                    items(AVAILABLE_RIBBON_COLORS) { colorInt ->
                        val isSelected = colorInt == ribbonColor
                        Box(
                            modifier = Modifier
                                .size(28.dp)
                                .clip(CircleShape)
                                .background(Color(colorInt))
                                .border(
                                    width = if (isSelected) 2.dp else 1.dp,
                                    color = if (isSelected) Color.White else Color.Gray.copy(alpha = 0.5f),
                                    shape = CircleShape
                                )
                                .clickable { onSelectRibbonColor(colorInt) },
                            contentAlignment = Alignment.Center
                        ) {
                            if (isSelected) {
                                Icon(
                                    Icons.Default.Check,
                                    contentDescription = "चयनित",
                                    tint = Color.White,
                                    modifier = Modifier.size(16.dp)
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(6.dp))

            // 2. Auspicious 1-Tap Badges Tray
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "शुभ प्रतीक:",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(end = 6.dp)
                )

                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.weight(1f)
                ) {
                    items(STICKER_BADGES) { badge ->
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = MaterialTheme.colorScheme.surfaceVariant,
                            modifier = Modifier.clickable { onAddBadge(badge) }
                        ) {
                            Text(
                                text = badge,
                                fontSize = 18.sp,
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp)
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(6.dp))

            // 3. Navigation Controls: Layers & Typography Bar
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(
                    onClick = onOpenLayers,
                    modifier = Modifier.size(44.dp)
                ) {
                    Icon(Icons.Default.Layers, contentDescription = stringResource(R.string.layers_panel))
                }

                if (isTextSelected) {
                    IconButton(
                        onClick = onOpenTypography,
                        modifier = Modifier.size(44.dp)
                    ) {
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
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
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
private fun PosterCanvasContainer(
    layers: List<EditorLayer>,
    aspectRatio: Float,
    ribbonColor: Int,
    candidateProfile: CandidateProfile?,
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
            .padding(12.dp),
        contentAlignment = Alignment.Center
    ) {
        // Calculate bounded dimensions respecting target aspect ratio
        val containerWidth = maxWidth
        val containerHeight = maxHeight
        val desiredWidth = minOf(containerWidth, containerHeight * aspectRatio)
        val desiredHeight = desiredWidth / aspectRatio

        Box(
            modifier = Modifier
                .width(desiredWidth)
                .height(desiredHeight)
                .shadow(12.dp, RoundedCornerShape(4.dp))
                .clip(RoundedCornerShape(4.dp))
                .background(Color.White)
                .pointerInput(Unit) {
                    detectTapGestures(
                        onTap = { onSelectLayer(null) }
                    )
                }
        ) {
            // Background is drawn first
            val bgLayer = layers.find { it is EditorLayer.BackgroundLayer } as? EditorLayer.BackgroundLayer
            val bgModifier = Modifier.fillMaxSize()

            if (bgLayer?.backgroundUrl != null && !bgLayer.backgroundUrl.startsWith("gradient:")) {
                AsyncImage(
                    model = bgLayer.backgroundUrl,
                    contentDescription = null,
                    modifier = bgModifier,
                    contentScale = ContentScale.Crop
                )
            } else if (bgLayer?.backgroundUrl != null && bgLayer.backgroundUrl.startsWith("gradient:")) {
                Box(modifier = bgModifier.background(parseGradientBrush(bgLayer.backgroundUrl)))
            } else {
                Box(modifier = bgModifier.background(bgLayer?.let { Color(it.color) } ?: Color.White))
            }

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

            // Auto-bound Nameplate Ribbon at bottom of poster
            if (candidateProfile != null) {
                Surface(
                    color = Color(ribbonColor),
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp, horizontal = 8.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "${candidateProfile.candidateName} • ${candidateProfile.designation}",
                            color = Color.White,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        Text(
                            text = "ग्राम पंचायत: ${candidateProfile.gramPanchayat} (${candidateProfile.district})",
                            color = Color.Yellow,
                            fontSize = 10.sp,
                            fontWeight = FontWeight.SemiBold,
                            textAlign = TextAlign.Center,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
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
                        textAlign = TextAlign.Center,
                        modifier = Modifier.semantics {
                            contentDescription = "पोस्टर टेक्स्ट: ${layer.text}"
                        }
                    )
                }
            }
            is EditorLayer.ImageLayer -> {
                val imageModel = layer.bitmap ?: layer.imageUrl ?: layer.imagePath
                if (imageModel != null) {
                    AsyncImage(
                        model = imageModel,
                        contentDescription = layer.name,
                        modifier = Modifier
                            .size(140.dp)
                            .clip(RoundedCornerShape(8.dp)),
                        contentScale = ContentScale.Fit
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .size(110.dp)
                            .clip(CircleShape)
                            .background(Color.White.copy(alpha = 0.85f))
                            .border(1.5.dp, MaterialTheme.colorScheme.primary, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Default.Person,
                            contentDescription = layer.name,
                            tint = Color.DarkGray,
                            modifier = Modifier.size(70.dp)
                        )
                    }
                }
            }
            is EditorLayer.StickerLayer -> {
                if (layer.bitmap != null) {
                    AsyncImage(
                        model = layer.bitmap,
                        contentDescription = layer.name,
                        modifier = Modifier.size(80.dp)
                    )
                } else {
                    Text(
                        text = layer.symbolKey ?: "⭐",
                        fontSize = 42.sp,
                        textAlign = TextAlign.Center
                    )
                }
            }
            is EditorLayer.BackgroundLayer -> Unit
        }
    }
}

private fun parseGradientBrush(url: String): Brush {
    if (url.startsWith("gradient:")) {
        val hexes = url.removePrefix("gradient:").split(":")
        val colors = hexes.mapNotNull { hex ->
            runCatching { Color(android.graphics.Color.parseColor(hex)) }.getOrNull()
        }
        if (colors.size >= 2) {
            return Brush.verticalGradient(colors)
        }
    }
    return Brush.verticalGradient(listOf(Color(0xFFFF6A1B), Color(0xFF138808)))
}
