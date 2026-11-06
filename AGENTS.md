# Poster Maker (GramPradhan Poster Studio) Project Rules

## Architecture & Tech Stack
- **Language**: Kotlin 2.x
- **UI**: Jetpack Compose (Material 3) with Unidirectional Data Flow (StateFlow / ViewModel)
- **DI**: Hilt (`@HiltViewModel`, `@Inject`)
- **Persistence**: Room with KSP
- **Target Platform**: Android minSdk 26, targetSdk 35

## Engineering Guidelines
1. **Compose Idioms**:
   - Keep Composables stateless where possible; hoist state and pass event lambdas up.
   - Use `remember` and `derivedStateOf` appropriately to avoid unnecessary recomposition.
   - Always provide previews and handle dark/light themes cleanly.
2. **ViewModel & State**:
   - Expose immutable `StateFlow<UiState>` to Compose UI; handle one-off events with Channels/SharedFlow.
   - Never pass `Context` into ViewModels.
3. **Verification**:
   - After any Kotlin/Android code changes, verify with `./gradlew compileDebugKotlin` or `./gradlew testDebugUnitTest`.
   - Never leave uncompiled code or broken imports in the repository.
