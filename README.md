# GramPradhan Poster Studio (ग्रामप्रधान पोस्टर स्टूडियो)

[![Android CI/CD](https://github.com/codeturbulent/Postermaker/actions/workflows/android.yml/badge.svg)](https://github.com/codeturbulent/Postermaker/actions/workflows/android.yml)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.0.21-purple.svg)](https://kotlinlang.org)
[![Android](https://img.shields.io/badge/MinSDK-26%20(Android%208.0)-brightgreen.svg)](https://developer.android.com)
[![Compose](https://img.shields.io/badge/Jetpack%20Compose-Material%203-blue.svg)](https://developer.android.com/jetpack/compose)
[![ML Kit](https://img.shields.io/badge/ML%20Kit-On--Device%20Selfie%20Segmentation-orange.svg)](https://developers.google.com/ml-kit)

**GramPradhan Poster Studio** is a native, offline-first Android application designed for non-technical Gram Pradhan candidates, sitting Pradhans, BDC/Zila Panchayat members, and local party workers across Bharat's Tier-2/Tier-3 markets. It empowers users on low-end hardware (2–4 GB RAM, Android 8.0+) to generate professional, print-ready flex banners in under 2 minutes completely offline.

---

## 🚀 Key Architectural Highlights

- 🇮🇳 **Hindi-First & Regional Ergonomics**: App default locale set to `hi-IN` with full Devanagari typography, matra-safe line wrapping via `BreakIterator`, honorific prefix normalization (श्री, श्रीमती, सौ., कु., डॉ.), and administrative hierarchy formatting.
- ⚡ **Offline-First On-Device AI**: Bundled Google ML Kit Selfie Segmentation (`com.google.mlkit:segmentation-selfie`) with custom separable 2D Gaussian blur edge feathering and native resolution preservation. Zero cloud calls or external dependencies required.
- 🎨 **Interactive Jetpack Compose Canvas**:
  - Pan, pinch-zoom, and rotation gesture processing (`detectTransformGestures`) bound strictly to the active layer.
  - Double-tap inline text editing overlay with `BasicTextField`.
  - 8 Devanagari Google Fonts (**Rozha One, Baloo Bhai 2, Kalam, Noto Sans Devanagari, Poppins, Mukta, Tiro Devanagari Hindi, Yatra One**).
  - Curved-text arc control (-180° to +180°), outline stroke widths (0–8dp), and drop shadows.
- 💾 **Robust Offline Persistence**: Room 2.6+ schema with custom native JSON `TypeConverters` for layers, slots, and candidate brand kit models.
- 🖨️ **High-DPI Print & Flex Banner Exporter**:
  - Dual export paths: Compose tree off-screen renderer and canvas-based layer exporter.
  - RAM-aware export engine capping flex banners to 6000px on devices with < 6 GB RAM to prevent OOM.
  - Adaptive JPEG quality compression (target $\le 2$ MB for WhatsApp status) and lossless PNG for physical flex printing.
- 🧪 **Unit & Instrumentation Testing**: JUnit 5, Turbine for reactive Room `Flow` testing, MockK, Robolectric, and Compose UI gesture test automation.

---

## 🛠️ Tech Stack & Constraints

| Component | Specification |
| :--- | :--- |
| **Language & Tooling** | Kotlin 2.0.21, AGP 8.7.2, KSP 2.0.21-1.0.28 |
| **UI Framework** | Jetpack Compose (Material 3), Compose Navigation |
| **Architecture** | Clean Architecture + MVVM + UDF (Unidirectional Data Flow) |
| **Local Database** | Room 2.6.1 (`AppDatabase` with Coroutines & Flow) |
| **Machine Learning** | Google ML Kit Bundled Selfie Segmenter (Offline) |
| **Image Pipeline** | Coil 3 (SVG / Network / Bitmap caching) |
| **Target Platforms** | Android 8.0+ (API 26 to API 35) |
| **CI/CD** | GitHub Actions with JDK 17 & Gradle 8.11.1 |

---

## 📂 Repository Structure

```
poster_maker/
├── .github/workflows/android.yml  # GitHub Actions CI/CD workflow
├── gradle/libs.versions.toml      # Pinned dependency catalog
├── app/
│   ├── build.gradle.kts           # AGP + Compose + Room build script
│   ├── proguard-rules.pro         # ProGuard / R8 shrink rules
│   └── src/
│       ├── main/
│       │   ├── AndroidManifest.xml
│       │   ├── res/values/strings.xml    # Default Hindi resources
│       │   ├── res/values-en/strings.xml # English fallback resources
│       │   └── java/com/grampradhan/posterstudio/
│       │       ├── core/data/            # Room Database, DAOs, TypeConverters
│       │       ├── core/formatter/       # DevanagariTextFormatter
│       │       ├── ml/                   # MLKitBackgroundRemover
│       │       ├── export/               # BitmapExportEngine
│       │       └── ui/                   # EditorScreen, ProfileScreen & ViewModels
│       ├── test/                         # Unit tests (Formatter, DAO, ViewModel)
│       └── androidTest/                  # Compose UI test (Gestures & text edit)
```
