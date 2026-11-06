package com.grampradhan.posterstudio

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.grampradhan.posterstudio.ui.editor.EditorScreen
import com.grampradhan.posterstudio.ui.editor.EditorViewModel
import com.grampradhan.posterstudio.ui.home.HomeScreen
import com.grampradhan.posterstudio.ui.home.HomeViewModel
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

                    NavHost(navController = navController, startDestination = "home") {
                        composable("home") {
                            val homeViewModel: HomeViewModel = hiltViewModel()
                            HomeScreen(
                                viewModel = homeViewModel,
                                onNavigateToProfile = {
                                    navController.navigate("profile")
                                },
                                onSelectTemplate = { templateId ->
                                    navController.navigate("editor/$templateId")
                                }
                            )
                        }

                        composable("profile") {
                            val profileViewModel: ProfileViewModel = hiltViewModel()
                            ProfileScreen(
                                viewModel = profileViewModel,
                                onNavigateToEditor = {
                                    navController.navigate("home") {
                                        popUpTo("home") { inclusive = true }
                                    }
                                }
                            )
                        }

                        composable(
                            route = "editor/{templateId}",
                            arguments = listOf(navArgument("templateId") { type = NavType.StringType })
                        ) { backStackEntry ->
                            val templateId = backStackEntry.arguments?.getString("templateId") ?: "default"
                            val editorViewModel: EditorViewModel = hiltViewModel()

                            LaunchedEffect(templateId) {
                                editorViewModel.loadTemplate(templateId)
                            }

                            EditorScreen(
                                viewModel = editorViewModel,
                                onNavigateToExport = {
                                    // Navigate to Export or trigger sharing
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
