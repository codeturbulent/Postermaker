package com.grampradhan.posterstudio.ui.editor

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Flip
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.LockOpen
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.grampradhan.posterstudio.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LayerPanelBottomSheet(
    layers: List<EditorLayer>,
    selectedLayerId: String?,
    onSelectLayer: (String) -> Unit,
    onBringForward: () -> Unit,
    onSendBackward: () -> Unit,
    onToggleLock: () -> Unit,
    onFlipHorizontal: () -> Unit,
    onDelete: () -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = stringResource(R.string.layers_panel),
                    style = MaterialTheme.typography.titleMedium
                )
                IconButton(
                    onClick = onDismiss,
                    modifier = Modifier.size(48.dp)
                ) {
                    Icon(
                        Icons.Default.Close,
                        contentDescription = "लेयर्स बंद करें"
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Action Bar for Active Layer
            if (selectedLayerId != null) {
                val activeLayer = layers.find { it.id == selectedLayerId }
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 4.dp),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    IconButton(
                        onClick = onBringForward,
                        modifier = Modifier.size(48.dp),
                        enabled = activeLayer !is EditorLayer.BackgroundLayer
                    ) {
                        Icon(Icons.Default.ArrowUpward, contentDescription = "आगे लाएं (Bring Forward)")
                    }
                    IconButton(
                        onClick = onSendBackward,
                        modifier = Modifier.size(48.dp),
                        enabled = activeLayer !is EditorLayer.BackgroundLayer
                    ) {
                        Icon(Icons.Default.ArrowDownward, contentDescription = "पीछे ले जाएं (Send Backward)")
                    }
                    IconButton(
                        onClick = onFlipHorizontal,
                        modifier = Modifier.size(48.dp),
                        enabled = activeLayer !is EditorLayer.BackgroundLayer && !activeLayer!!.isLocked
                    ) {
                        Icon(Icons.Default.Flip, contentDescription = "उलटें (Flip Horizontal)")
                    }
                    IconButton(
                        onClick = onToggleLock,
                        modifier = Modifier.size(48.dp),
                        enabled = activeLayer !is EditorLayer.BackgroundLayer
                    ) {
                        Icon(
                            if (activeLayer?.isLocked == true) Icons.Default.Lock else Icons.Default.LockOpen,
                            contentDescription = if (activeLayer?.isLocked == true) "अनलॉक करें" else "लॉक करें"
                        )
                    }
                    IconButton(
                        onClick = onDelete,
                        modifier = Modifier.size(48.dp),
                        enabled = activeLayer !is EditorLayer.BackgroundLayer
                    ) {
                        Icon(
                            Icons.Default.Delete,
                            contentDescription = "हटाएं (Delete)",
                            tint = MaterialTheme.colorScheme.error
                        )
                    }
                }
                HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))
            }

            // Ordered Layer List (Top-to-Bottom in visual order: descending zIndex)
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(260.dp)
            ) {
                val visualOrder = layers.sortedByDescending { it.zIndex }
                items(visualOrder, key = { it.id }) { layer ->
                    val isSelected = layer.id == selectedLayerId
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(
                                if (isSelected) MaterialTheme.colorScheme.primaryContainer else Color.Transparent
                            )
                            .clickable { onSelectLayer(layer.id) }
                            .padding(horizontal = 12.dp, vertical = 10.dp)
                            .semantics { contentDescription = "लेयर: ${layer.name}" },
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = when (layer) {
                                is EditorLayer.TextLayer -> "T  ${layer.text.take(20)}"
                                is EditorLayer.ImageLayer -> "🖼  ${layer.name}"
                                is EditorLayer.StickerLayer -> "⭐  ${layer.name}"
                                is EditorLayer.BackgroundLayer -> "🎨  ${layer.name}"
                            },
                            style = MaterialTheme.typography.bodyMedium
                        )

                        if (layer.isLocked) {
                            Icon(
                                Icons.Default.Lock,
                                contentDescription = "यह लेयर लॉक है",
                                modifier = Modifier.size(20.dp),
                                tint = Color.Gray
                            )
                        }
                    }
                }
            }
        }
    }
}
