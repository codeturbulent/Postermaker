package com.grampradhan.posterstudio.ui.editor

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Slider
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.grampradhan.posterstudio.R

val DEVANAGARI_FONTS = listOf(
    "Rozha One",
    "Baloo Bhai 2",
    "Kalam",
    "Noto Sans Devanagari",
    "Poppins",
    "Mukta",
    "Tiro Devanagari Hindi",
    "Yatra One"
)

val PRESET_COLORS = listOf(
    Color(0xFFFF6A1B), // Saffron / Kesariya
    Color(0xFFFFFFFF), // White
    Color(0xFFFFD700), // Gold
    Color(0xFF000000), // Black
    Color(0xFF0055A5), // Royal Blue
    Color(0xFF138808), // Indian Green
    Color(0xFFD32F2F)  // Crimson Red
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TypographyBottomSheet(
    layer: EditorLayer.TextLayer,
    onDismiss: () -> Unit,
    onUpdateLayer: (EditorLayer.TextLayer) -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = stringResource(R.string.typography_settings),
                    style = MaterialTheme.typography.titleMedium
                )
                IconButton(
                    onClick = onDismiss,
                    modifier = Modifier.size(48.dp)
                ) {
                    Icon(
                        Icons.Default.Close,
                        contentDescription = "बंद करें"
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // 1. 8 Devanagari Font Picker
            Text(
                text = stringResource(R.string.font_family),
                style = MaterialTheme.typography.labelMedium
            )
            LazyRow(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(DEVANAGARI_FONTS) { font ->
                    FilterChip(
                        selected = layer.fontName == font,
                        onClick = { onUpdateLayer(layer.copy(fontName = font)) },
                        label = { Text(font) },
                        modifier = Modifier.semantics {
                            contentDescription = "फॉन्ट शैली: $font"
                        }
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // 2. Color Palette
            Text(
                text = stringResource(R.string.text_color),
                style = MaterialTheme.typography.labelMedium
            )
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                PRESET_COLORS.forEach { color ->
                    val isSelected = layer.textColor == color.toArgb()
                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(color)
                            .border(
                                width = if (isSelected) 3.dp else 1.dp,
                                color = if (isSelected) MaterialTheme.colorScheme.primary else Color.Gray,
                                shape = CircleShape
                            )
                            .clickable {
                                onUpdateLayer(layer.copy(textColor = color.toArgb()))
                            }
                            .semantics { contentDescription = "रंग चयन" }
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // 3. Stroke (Border) Slider (0 - 8dp)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = stringResource(R.string.stroke_width),
                    style = MaterialTheme.typography.labelMedium
                )
                Text("${layer.strokeWidthDp.toInt()} dp")
            }
            Slider(
                value = layer.strokeWidthDp,
                onValueChange = { onUpdateLayer(layer.copy(strokeWidthDp = it)) },
                valueRange = 0f..8f,
                modifier = Modifier.fillMaxWidth()
            )

            // 4. Curved Text Arc Slider (-180 to +180 degrees)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = stringResource(R.string.curved_arc),
                    style = MaterialTheme.typography.labelMedium
                )
                Text("${layer.curvedArc.toInt()}°")
            }
            Slider(
                value = layer.curvedArc,
                onValueChange = { onUpdateLayer(layer.copy(curvedArc = it)) },
                valueRange = -180f..180f,
                modifier = Modifier.fillMaxWidth()
            )

            // 5. Drop Shadow Toggle
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "शैडो (छाया प्रभाव)",
                    style = MaterialTheme.typography.bodyMedium
                )
                Switch(
                    checked = layer.hasShadow,
                    onCheckedChange = { onUpdateLayer(layer.copy(hasShadow = it)) },
                    modifier = Modifier.size(48.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}
