package com.grampradhan.posterstudio.ui.editor

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.doubleClick
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipeRight
import com.grampradhan.posterstudio.core.data.db.CandidateProfileDao
import com.grampradhan.posterstudio.core.data.db.DraftDao
import com.grampradhan.posterstudio.core.data.repository.TemplateRepository
import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

class EditorGestureTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    private val draftDao: DraftDao = mockk(relaxed = true)
    private val templateRepository: TemplateRepository = mockk(relaxed = true)
    private val candidateProfileDao: CandidateProfileDao = mockk(relaxed = true)

    @Test
    fun testEditorGesture_panActiveLayer_updatesLayerTranslation() {
        val viewModel = EditorViewModel(draftDao, templateRepository, candidateProfileDao)

        composeTestRule.setContent {
            EditorScreen(
                viewModel = viewModel,
                onNavigateToExport = {}
            )
        }

        // Verify initial candidate name text layer is displayed
        val candidateNode = composeTestRule.onNodeWithText("राजेश कुमार यादव (ग्राम प्रधान)")
        candidateNode.assertIsDisplayed()

        val initialX = viewModel.uiState.value.layers
            .find { it.id == "txt_candidate_name" }?.translationX ?: 0f

        // Perform swipe right drag gesture on the active layer
        candidateNode.performTouchInput {
            swipeRight(startX = 100f, endX = 300f, durationMillis = 200)
        }

        // Verify translationX moved positively in state
        val updatedX = viewModel.uiState.value.layers
            .find { it.id == "txt_candidate_name" }?.translationX ?: 0f

        assertTrue("Layer translationX should increase following drag right", updatedX > initialX)
    }

    @Test
    fun testEditorGesture_doubleTapText_activatesInlineEditingMode() {
        val viewModel = EditorViewModel(draftDao, templateRepository, candidateProfileDao)

        composeTestRule.setContent {
            EditorScreen(
                viewModel = viewModel,
                onNavigateToExport = {}
            )
        }

        val candidateNode = composeTestRule.onNodeWithText("राजेश कुमार यादव (ग्राम प्रधान)")

        // Perform double-click on candidate text layer
        candidateNode.performTouchInput {
            doubleClick()
        }

        // Assert that inlineEditingTextId was set to this text layer in the ViewModel
        assertEquals("txt_candidate_name", viewModel.uiState.value.inlineEditingTextId)
    }
}
