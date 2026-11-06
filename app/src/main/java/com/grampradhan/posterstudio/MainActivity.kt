package com.grampradhan.posterstudio

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.grampradhan.posterstudio.ui.editor.EditorScreen
import com.grampradhan.posterstudio.ui.editor.EditorViewModel
import com.grampradhan.posterstudio.ui.profile.ProfileScreen
import com.grampradhan.posterstudio.ui.profile.ProfileViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    val navController = rememberNavController()

                    NavHost(navController = navController, startDestination = "profile") {
                        composable("profile") {
                            val profileViewModel: ProfileViewModel = hiltViewModel()
                            ProfileScreen(
                                viewModel = profileViewModel,
                                onNavigateToEditor = {
                                    navController.navigate("editor")
                                }
                            )
                        }
                        composable("editor") {
                            val editorViewModel: EditorViewModel = hiltViewModel()
                            EditorScreen(
                                viewModel = editorViewModel,
                                onNavigateToExport = {
                                    // Navigate to Export or trigger export flow
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
