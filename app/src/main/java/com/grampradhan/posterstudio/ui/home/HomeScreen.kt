package com.grampradhan.posterstudio.ui.home

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
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
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.Button
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.grampradhan.posterstudio.R
import com.grampradhan.posterstudio.core.data.model.CandidateProfile
import com.grampradhan.posterstudio.core.data.model.PosterTemplate
import com.grampradhan.posterstudio.core.data.model.SlotType
import com.grampradhan.posterstudio.core.data.model.TemplateCategory
import com.grampradhan.posterstudio.core.formatter.DevanagariTextFormatter
import kotlin.math.roundToInt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    viewModel: HomeViewModel,
    onNavigateToProfile: () -> Unit,
    onSelectTemplate: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    val uiState by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.app_name),
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold
                    )
                },
                actions = {
                    IconButton(
                        onClick = onNavigateToProfile,
                        modifier = Modifier.semantics { contentDescription = "प्रोफ़ाइल संपादित करें" }
                    ) {
                        Icon(Icons.Default.Edit, contentDescription = null)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            )
        },
        modifier = modifier
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // 1. Candidate Greeting Banner or Empty State CTA
            if (uiState.activeProfile != null) {
                CandidateGreetingCard(
                    profile = uiState.activeProfile!!,
                    onEditClick = onNavigateToProfile
                )
            } else {
                EmptyProfilePromptCard(onSetupClick = onNavigateToProfile)
            }

            Spacer(modifier = Modifier.height(8.dp))

            // 2. Category Horizontal Filter Chips
            CategoryFilterBar(
                selectedCategory = uiState.selectedCategory,
                onSelectCategory = viewModel::onSelectCategory
            )

            Spacer(modifier = Modifier.height(8.dp))

            // 3. Auto-Filled Live Poster Grid
            LazyVerticalGrid(
                columns = GridCells.Adaptive(minSize = 160.dp),
                contentPadding = PaddingValues(16.dp),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(uiState.templates, key = { it.id }) { template ->
                    AutoFilledTemplateCard(
                        template = template,
                        profile = uiState.activeProfile,
                        onClick = { onSelectTemplate(template.id) }
                    )
                }
            }
        }
    }
}

@Composable
private fun CandidateGreetingCard(
    profile: CandidateProfile,
    onEditClick: () -> Unit
) {
    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .clickable { onEditClick() },
        shape = RoundedCornerShape(12.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(52.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primaryContainer),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Default.Person,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onPrimaryContainer,
                    modifier = Modifier.size(32.dp)
                )
            }

            Spacer(modifier = Modifier.width(16.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "नमस्ते ${profile.candidateName} जी!",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "${profile.designation} • ग्राम पंचायत: ${profile.gramPanchayat}",
                    style = MaterialTheme.typography.bodySmall,
                    color = Color.Gray,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

@Composable
private fun EmptyProfilePromptCard(onSetupClick: () -> Unit) {
    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        shape = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "पहले अपनी प्रोफ़ाइल और चुनाव चिन्ह सेट करें",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "सभी चुनावी व त्योहार पोस्टर आपके नाम व फ़ोटो से स्वतः तैयार हो जाएंगे।",
                style = MaterialTheme.typography.bodySmall,
                color = Color.Gray,
                textAlign = TextAlign.Center
            )
            Spacer(modifier = Modifier.height(12.dp))
            Button(onClick = onSetupClick) {
                Icon(Icons.Default.Add, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text(stringResource(R.string.create_profile_cta))
            }
        }
    }
}

@Composable
private fun CategoryFilterBar(
    selectedCategory: TemplateCategory,
    onSelectCategory: (TemplateCategory) -> Unit
) {
    val categories = listOf(
        Pair(TemplateCategory.ALL, stringResource(R.string.category_all)),
        Pair(TemplateCategory.ELECTION_CAMPAIGN, stringResource(R.string.category_election)),
        Pair(TemplateCategory.FESTIVAL_GREETINGS, stringResource(R.string.category_festival)),
        Pair(TemplateCategory.VIKAS_KARYA, stringResource(R.string.category_development)),
        Pair(TemplateCategory.BIRTHDAY_CONGRATULATIONS, stringResource(R.string.category_birthday))
    )

    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        items(categories) { (category, title) ->
            FilterChip(
                selected = selectedCategory == category,
                onClick = { onSelectCategory(category) },
                label = { Text(title) }
            )
        }
    }
}

/**
 * Renders a live auto-filled poster thumbnail compositing brand kit details into template slots.
 */
@Composable
private fun AutoFilledTemplateCard(
    template: PosterTemplate,
    profile: CandidateProfile?,
    onClick: () -> Unit
) {
    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .shadow(4.dp, RoundedCornerShape(8.dp)),
        shape = RoundedCornerShape(8.dp)
    ) {
        Column {
            BoxWithConstraints(
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(template.aspectRatio.widthRatio / template.aspectRatio.heightRatio)
                    .clip(RoundedCornerShape(topStart = 8.dp, topEnd = 8.dp))
            ) {
                val cardWidth = maxWidth
                val cardHeight = maxHeight

                // 1. Template Background
                val backgroundBrush = parseGradientBrush(template.backgroundUrl)
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(backgroundBrush)
                )

                // 2. Predefined Template Text
                template.predefinedTextLayers.firstOrNull()?.let { headline ->
                    Text(
                        text = headline.text,
                        color = Color.White,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center,
                        modifier = Modifier
                            .fillMaxWidth(0.9f)
                            .align(Alignment.TopCenter)
                            .padding(top = 8.dp),
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                // 3. Auto-bound Brand Kit Overlays
                if (profile != null) {
                    template.slotConfigs.forEach { slot ->
                        when (slot.slotType) {
                            SlotType.CANDIDATE_PHOTO -> {
                                Box(
                                    modifier = Modifier
                                        .align(Alignment.BottomStart)
                                        .padding(start = 8.dp, bottom = 24.dp)
                                        .size(cardWidth * 0.35f)
                                        .clip(CircleShape)
                                        .background(Color.White.copy(alpha = 0.9f))
                                        .border(1.dp, MaterialTheme.colorScheme.primary, CircleShape),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Icon(
                                        Icons.Default.Person,
                                        contentDescription = null,
                                        tint = Color.DarkGray,
                                        modifier = Modifier.size(cardWidth * 0.22f)
                                    )
                                }
                            }
                            SlotType.PARTY_SYMBOL -> {
                                Box(
                                    modifier = Modifier
                                        .align(Alignment.TopEnd)
                                        .padding(top = 6.dp, end = 6.dp)
                                        .size(cardWidth * 0.22f)
                                        .clip(CircleShape)
                                        .background(Color.White)
                                        .border(1.dp, Color.LightGray, CircleShape),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = profile.partySymbolPath?.take(2) ?: "⭐",
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        textAlign = TextAlign.Center
                                    )
                                }
                            }
                            SlotType.VILLAGE_TEXT -> {
                                Surface(
                                    color = Color.Black.copy(alpha = 0.75f),
                                    modifier = Modifier
                                        .align(Alignment.BottomCenter)
                                        .fillMaxWidth()
                                ) {
                                    Text(
                                        text = "${profile.candidateName} (${profile.gramPanchayat})",
                                        color = Color.Yellow,
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        textAlign = TextAlign.Center,
                                        modifier = Modifier.padding(vertical = 3.dp),
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                }
                            }
                            else -> Unit
                        }
                    }
                }
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = when (template.category) {
                        TemplateCategory.ELECTION_CAMPAIGN -> "चुनावी प्रचार"
                        TemplateCategory.FESTIVAL_GREETINGS -> "त्योहार"
                        TemplateCategory.VIKAS_KARYA -> "विकास कार्य"
                        TemplateCategory.BIRTHDAY_CONGRATULATIONS -> "बधाई व सम्मान"
                        TemplateCategory.ALL -> "पोस्टर"
                    },
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.SemiBold
                )

                Icon(
                    Icons.Default.ArrowForward,
                    contentDescription = "संपादित करें",
                    modifier = Modifier.size(16.dp),
                    tint = Color.Gray
                )
            }
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
