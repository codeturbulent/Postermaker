package com.grampradhan.posterstudio.ui.profile

import android.graphics.Bitmap
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddAPhoto
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.grampradhan.posterstudio.R
import com.grampradhan.posterstudio.ui.editor.PRESET_COLORS

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel,
    onNavigateToEditor: () -> Unit,
    modifier: Modifier = Modifier
) {
    val state by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    LaunchedEffect(state) {
        if (state is ProfileUiState.Content && (state as ProfileUiState.Content).isSaveSuccess) {
            onNavigateToEditor()
        }
    }

    when (val uiState = state) {
        is ProfileUiState.Loading -> {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
        }
        is ProfileUiState.Error -> {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text(text = uiState.messageHindi, color = MaterialTheme.colorScheme.error)
            }
        }
        is ProfileUiState.Content -> {
            val photoPickerLauncher = rememberLauncherForActivityResult(
                contract = ActivityResultContracts.GetContent()
            ) { uri: Uri? ->
                uri?.let {
                    val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        ImageDecoder.decodeBitmap(ImageDecoder.createSource(context.contentResolver, it))
                    } else {
                        @Suppress("DEPRECATION")
                        MediaStore.Images.Media.getBitmap(context.contentResolver, it)
                    }
                    viewModel.onIntent(ProfileIntent.PhotoSelected(bitmap))
                }
            }

            Scaffold(
                floatingActionButton = {
                    ExtendedFloatingActionButton(
                        onClick = { viewModel.onIntent(ProfileIntent.SaveProfile) },
                        icon = { Icon(Icons.Default.Save, contentDescription = null) },
                        text = { Text(stringResource(R.string.btn_save_profile)) },
                        expanded = true,
                        containerColor = if (uiState.isSaveEnabled) MaterialTheme.colorScheme.primary else Color.Gray,
                        modifier = Modifier.semantics {
                            contentDescription = "प्रोफ़ाइल सुरक्षित करें बटन"
                        }
                    )
                },
                modifier = modifier
            ) { padding ->
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(padding)
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    item {
                        Text(
                            text = stringResource(R.string.profile_title),
                            style = MaterialTheme.typography.headlineSmall,
                            modifier = Modifier.padding(vertical = 8.dp)
                        )
                    }

                    // 1. Candidate Full Name
                    item {
                        OutlinedTextField(
                            value = uiState.candidateName,
                            onValueChange = { viewModel.onIntent(ProfileIntent.NameChanged(it)) },
                            label = { Text(stringResource(R.string.candidate_name_label)) },
                            placeholder = { Text(stringResource(R.string.candidate_name_hint)) },
                            isError = uiState.nameErrorHindi != null,
                            supportingText = {
                                uiState.nameErrorHindi?.let { Text(it, color = MaterialTheme.colorScheme.error) }
                            },
                            modifier = Modifier.fillMaxWidth()
                        )
                    }

                    // 2. Designation Dropdown
                    item {
                        var dropdownExpanded by remember { mutableStateOf(false) }
                        ExposedDropdownMenuBox(
                            expanded = dropdownExpanded,
                            onExpandedChange = { dropdownExpanded = it }
                        ) {
                            OutlinedTextField(
                                value = uiState.designation,
                                onValueChange = {},
                                readOnly = true,
                                label = { Text(stringResource(R.string.designation_label)) },
                                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = dropdownExpanded) },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .menuAnchor()
                            )
                            ExposedDropdownMenu(
                                expanded = dropdownExpanded,
                                onDismissRequest = { dropdownExpanded = false }
                            ) {
                                ProfileUiState.DESIGNATION_PRESETS.forEach { preset ->
                                    DropdownMenuItem(
                                        text = { Text(preset) },
                                        onClick = {
                                            viewModel.onIntent(ProfileIntent.DesignationChanged(preset))
                                            dropdownExpanded = false
                                        }
                                    )
                                }
                            }
                        }

                        if (uiState.designation == "अन्य (लिखें)") {
                            Spacer(modifier = Modifier.height(8.dp))
                            OutlinedTextField(
                                value = uiState.customDesignation,
                                onValueChange = { viewModel.onIntent(ProfileIntent.CustomDesignationChanged(it)) },
                                label = { Text("अपना पद लिखें") },
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                    }

                    // 3. Panchayat, Block, District
                    item {
                        OutlinedTextField(
                            value = uiState.gramPanchayat,
                            onValueChange = { viewModel.onIntent(ProfileIntent.GramPanchayatChanged(it)) },
                            label = { Text(stringResource(R.string.gram_panchayat_label)) },
                            placeholder = { Text(stringResource(R.string.gram_panchayat_hint)) },
                            isError = uiState.panchayatErrorHindi != null,
                            supportingText = {
                                uiState.panchayatErrorHindi?.let { Text(it, color = MaterialTheme.colorScheme.error) }
                            },
                            modifier = Modifier.fillMaxWidth()
                        )
                    }

                    item {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            OutlinedTextField(
                                value = uiState.vikasKhandBlock,
                                onValueChange = { viewModel.onIntent(ProfileIntent.BlockChanged(it)) },
                                label = { Text(stringResource(R.string.vikas_khand_label)) },
                                placeholder = { Text(stringResource(R.string.vikas_khand_hint)) },
                                modifier = Modifier.weight(1f)
                            )
                            OutlinedTextField(
                                value = uiState.district,
                                onValueChange = { viewModel.onIntent(ProfileIntent.DistrictChanged(it)) },
                                label = { Text(stringResource(R.string.district_label)) },
                                placeholder = { Text(stringResource(R.string.district_hint)) },
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }

                    // 4. Photo Picker & AI Cutout
                    item {
                        ElevatedCard(modifier = Modifier.fillMaxWidth()) {
                            Column(
                                modifier = Modifier.padding(16.dp),
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Text(
                                    text = "प्रत्याशी फ़ोटो और बैकग्राउंड रिमूवल",
                                    style = MaterialTheme.typography.titleMedium
                                )
                                Spacer(modifier = Modifier.height(12.dp))

                                val displayBitmap = if (uiState.removeBackgroundEnabled && uiState.cutoutPhotoBitmap != null) {
                                    uiState.cutoutPhotoBitmap
                                } else {
                                    uiState.rawPhotoBitmap
                                }

                                Box(
                                    modifier = Modifier
                                        .size(150.dp)
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(Color.LightGray)
                                        .clickable { photoPickerLauncher.launch("image/*") },
                                    contentAlignment = Alignment.Center
                                ) {
                                    if (displayBitmap != null) {
                                        Image(
                                            bitmap = displayBitmap.asImageBitmap(),
                                            contentDescription = "प्रत्याशी फ़ोटो प्रीव्यू",
                                            modifier = Modifier.fillMaxSize()
                                        )
                                    } else {
                                        Icon(
                                            Icons.Default.AddAPhoto,
                                            contentDescription = stringResource(R.string.btn_pick_photo),
                                            modifier = Modifier.size(48.dp),
                                            tint = Color.DarkGray
                                        )
                                    }

                                    if (uiState.isRemovingBackground) {
                                        Box(
                                            modifier = Modifier
                                                .fillMaxSize()
                                                .background(Color.Black.copy(alpha = 0.5f)),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            CircularProgressIndicator(color = Color.White)
                                        }
                                    }
                                }

                                Spacer(modifier = Modifier.height(12.dp))

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = stringResource(R.string.btn_remove_background),
                                        style = MaterialTheme.typography.bodyMedium
                                    )
                                    Switch(
                                        checked = uiState.removeBackgroundEnabled,
                                        onCheckedChange = { viewModel.onIntent(ProfileIntent.ToggleRemoveBackground(it)) },
                                        enabled = uiState.rawPhotoBitmap != null && !uiState.isRemovingBackground
                                    )
                                }
                            }
                        }
                    }

                    // 5. Party Symbol Picker
                    item {
                        Text(
                            text = stringResource(R.string.party_symbol_title),
                            style = MaterialTheme.typography.titleMedium
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Box(modifier = Modifier.height(140.dp)) {
                            LazyVerticalGrid(
                                columns = GridCells.Fixed(4),
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                verticalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                items(ProfileUiState.BUNDLED_PARTY_SYMBOLS) { symbol ->
                                    val isSelected = uiState.selectedPartySymbol == symbol
                                    FilterChip(
                                        selected = isSelected,
                                        onClick = { viewModel.onIntent(ProfileIntent.PartySymbolSelected(symbol)) },
                                        label = { Text(symbol) }
                                    )
                                }
                            }
                        }
                    }

                    // 6. Primary Brand Color
                    item {
                        Text(
                            text = stringResource(R.string.primary_color_title),
                            style = MaterialTheme.typography.titleMedium
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            PRESET_COLORS.forEach { color ->
                                val hex = String.format("#%06X", 0xFFFFFF and color.value.toInt())
                                val isSelected = uiState.primaryColorHex.equals(hex, ignoreCase = true)
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
                                        .clickable { viewModel.onIntent(ProfileIntent.PrimaryColorSelected(hex)) }
                                )
                            }
                        }
                    }

                    // Bottom padding for FAB
                    item {
                        Spacer(modifier = Modifier.height(72.dp))
                    }
                }
            }
        }
    }
}
