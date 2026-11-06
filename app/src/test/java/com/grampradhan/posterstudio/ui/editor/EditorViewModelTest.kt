package com.grampradhan.posterstudio.ui.editor

import app.cash.turbine.test
import com.grampradhan.posterstudio.core.data.db.CandidateProfileDao
import com.grampradhan.posterstudio.core.data.db.DraftDao
import com.grampradhan.posterstudio.core.data.repository.ImageSearchResult
import com.grampradhan.posterstudio.core.data.repository.ImageSearchService
import com.grampradhan.posterstudio.core.data.repository.TemplateRepository
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class EditorViewModelTest {

    private val testDispatcher = StandardTestDispatcher()
    private val draftDao: DraftDao = mockk(relaxed = true)
    private val templateRepository: TemplateRepository = mockk(relaxed = true)
    private val candidateProfileDao: CandidateProfileDao = mockk(relaxed = true)
    private val imageSearchService: ImageSearchService = mockk(relaxed = true)

    private lateinit var viewModel: EditorViewModel

    @BeforeEach
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        viewModel = EditorViewModel(
            draftDao = draftDao,
            templateRepository = templateRepository,
            candidateProfileDao = candidateProfileDao,
            imageSearchService = imageSearchService
        )
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    @DisplayName("Slogan Bank: Applying slogan updates existing slogan layer or creates new layer")
    fun testApplySloganUpdatesCanvas() = runTest {
        viewModel.uiState.test {
            val initial = awaitItem()
            val sloganLayerBefore = initial.layers.find { it.id == "txt_slogan" } as? EditorLayer.TextLayer
            assertNotNull(sloganLayerBefore)

            // Select slogan layer first
            viewModel.selectLayer("txt_slogan")
            val selected = awaitItem()
            assertEquals("txt_slogan", selected.selectedLayerId)

            // Apply new slogan from Slogan Bank
            viewModel.applySlogan("गाँव की उन्नति, हमारा संकल्प")
            val updated = awaitItem()
            val sloganLayerAfter = updated.layers.find { it.id == "txt_slogan" } as? EditorLayer.TextLayer

            assertNotNull(sloganLayerAfter)
            assertEquals("गाँव की उन्नति, हमारा संकल्प", sloganLayerAfter?.text)
            assertFalse(updated.isSloganPickerVisible)
            assertTrue(updated.canUndo)

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    @DisplayName("Ribbon Color: Updating ribbon color updates editor state")
    fun testSetRibbonColor() = runTest {
        viewModel.uiState.test {
            val initial = awaitItem()
            val newColor = 0xFF1B5E20.toInt() // Bharat Green

            viewModel.setRibbonColor(newColor)
            val updated = awaitItem()

            assertEquals(newColor, updated.ribbonColor)
            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    @DisplayName("Aspect Ratio: Switching aspect ratio updates editor state")
    fun testSetAspectRatio() = runTest {
        viewModel.uiState.test {
            awaitItem()

            viewModel.setAspectRatio(0.8f) // 4:5 banner
            val updated = awaitItem()
            assertEquals(0.8f, updated.aspectRatio)

            viewModel.setAspectRatio(9f / 16f) // 9:16 WhatsApp status
            val statusState = awaitItem()
            assertEquals(9f / 16f, statusState.aspectRatio)

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    @DisplayName("Auspicious Badges: Adding a badge sticker adds a new StickerLayer")
    fun testAddStickerBadge() = runTest {
        viewModel.uiState.test {
            val initial = awaitItem()
            val initialCount = initial.layers.size

            viewModel.addStickerBadge("🪔")
            val updated = awaitItem()

            assertEquals(initialCount + 1, updated.layers.size)
            val added = updated.layers.last() as? EditorLayer.StickerLayer
            assertNotNull(added)
            assertEquals("🪔", added?.symbolKey)

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    @DisplayName("Stock Image Search: Adding stock image adds an ImageLayer to canvas")
    fun testAddImageFromSearch() = runTest {
        viewModel.uiState.test {
            val initial = awaitItem()
            val initialCount = initial.layers.size

            val result = ImageSearchResult(
                id = "test_img_1",
                title = "दीपावली दीया",
                thumbnailUrl = "https://example.com/thumb.jpg",
                fullUrl = "https://example.com/full.jpg",
                source = "Wikimedia",
                category = "त्यौहार"
            )

            viewModel.addImageFromSearch(result, asBackground = false)
            val updated = awaitItem()

            assertEquals(initialCount + 1, updated.layers.size)
            val added = updated.layers.last() as? EditorLayer.ImageLayer
            assertNotNull(added)
            assertEquals("https://example.com/full.jpg", added?.imageUrl)
            assertFalse(updated.isImageSearchVisible)

            cancelAndIgnoreRemainingEvents()
        }
    }

    @Test
    @DisplayName("Photo Alignment: Toggling photo alignment flips alignment left/right")
    fun testTogglePhotoAlignment() = runTest {
        viewModel.uiState.test {
            val initial = awaitItem()
            assertTrue(initial.photoAlignmentLeft)

            viewModel.togglePhotoAlignment()
            val updated = awaitItem()
            assertFalse(updated.photoAlignmentLeft)

            viewModel.togglePhotoAlignment()
            val flippedBack = awaitItem()
            assertTrue(flippedBack.photoAlignmentLeft)

            cancelAndIgnoreRemainingEvents()
        }
    }
}
