# Postermaker

[![Release Build & Publish](https://github.com/codeturbulent/Postermaker/actions/workflows/release.yml/badge.svg)](https://github.com/codeturbulent/Postermaker/actions/workflows/release.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Postermaker** (देसी पोस्टर मेकर) is a production-ready, null-safe Flutter mobile application designed for non-technical users in India (Panchayat representatives, political organizers, festive celebrants, and local business owners) to effortlessly create personalized, high-definition regional festival and political banners in seconds.

---

## ✨ Features

- 🇮🇳 **Authentic Regional Indian Aesthetics**: Pre-styled for Samajwadi, BJP, Panchayat Election, Birthday, and Festive banner layouts.
- 🪶 **Anti-Clipping Devanagari Typography**: Custom `StrokedText` widget with dual-pass outer stroke and drop shadows, backed by explicit `StrutStyle` line-height calculations so high Hindi matras (*ikaron*, *ekaron*, *chandrabindu*) and low matras (*u*, *oo*, *ri*) are never clipped.
- 🖼️ **Adaptive High-Resolution Compositor**: Built with `RepaintBoundary` + `LayoutBuilder` exporting crisp `1080x1080px` (1:1) and `1080x1350px` (4:5) PNGs independent of the device's physical screen size.
- 📸 **Photo Cutout & Emblem Picker**: Integrated cropping for user profile pictures (1:1 / 3:4) and party/election symbol badges with instant fallback placeholders.
- ⚡ **Interactive Live Customization**:
  - Live photo alignment toggling (Left / Right).
  - Ribbon accent color palette selector.
  - On-the-fly custom greeting headline text editor.
- 💾 **Local Persistence**: User profile (name, designation, tagline, phone, WhatsApp handle, image paths) automatically persisted across restarts via `shared_preferences`.
- 📲 **Modern Sharing & Saving**: Direct device gallery save via `gal` (MediaStore / Photos API) and instant WhatsApp/social sharing via `share_plus`.
- 🌐 **Offline Resilience**: Built-in multi-stop radial and linear gradients ensure the app displays rich decorative banners even without internet access.

---

## 🛠️ Architecture & Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Framework** | Flutter 3.24+ (Material Design 3 with `useMaterial3: true`) |
| **Language** | Dart 3.5+ (Strict Null-Safety) |
| **State Management** | `provider` (`ChangeNotifier`) |
| **Local Storage** | `shared_preferences` with JSON serialization |
| **Image Handling** | `image_picker` + `image_cropper` |
| **Compositing & Export** | Flutter `RepaintBoundary` + `RenderRepaintBoundary.toImage(pixelRatio: 3.0)` |
| **Gallery Storage** | `gal` |
| **Social Sharing** | `share_plus` |
| **Typography** | `google_fonts` (`Yatra One`, `Rozha One`, `Gotu`, `Poppins`) |

---

## 📁 Project Structure

```
Postermaker/
├── .github/
│   └── workflows/
│       └── release.yml          # Automated CI/CD Release Build & APK/AAB Publisher
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml  # Configured with UCropActivity & storage permissions
├── ios/
│   └── Runner/
│       └── Info.plist           # Configured with Photo Library & Camera permissions
├── lib/
│   ├── main.dart                # App entry point, Material 3 theming & Hindi localizations
│   ├── models/
│   │   ├── user_profile.dart    # UserProfile model with JSON serialization
│   │   └── poster_template.dart # Template models, categories & dummy templates
│   ├── providers/
│   │   └── poster_provider.dart # Central ChangeNotifier state manager
│   ├── utils/
│   │   └── image_exporter.dart  # High-definition PNG export, Gal save & SharePlus
│   ├── widgets/
│   │   ├── stroked_text.dart    # Devanagari stroked typography with StrutStyle
│   │   └── poster_canvas.dart   # Scaled layout compositor with multi-layer stack
│   └── screens/
│       ├── home_screen.dart     # Category filter chips & 2-column GridView
│       ├── profile_edit_screen.dart # Profile form with live ribbon preview
│       └── poster_editor_screen.dart # Interactive editor & sticky export buttons
├── test/
│   └── models_and_provider_test.dart # Automated unit test suite
└── pubspec.yaml                 # Exact compatible dependency versions
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.24.0)
- [Dart SDK](https://dart.dev/get-dart) (>= 3.5.0)
- Android Studio / Xcode

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/codeturbulent/Postermaker.git
   cd Postermaker
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run unit tests:
   ```bash
   flutter test
   ```

4. Launch the application:
   ```bash
   flutter run
   ```

---

## 📦 Automated Releases (CI/CD)

This repository includes a fully automated GitHub Actions workflow [`.github/workflows/release.yml`](.github/workflows/release.yml) that:
1. Triggers on pushes to `main`, tags matching `v*`, or manual `workflow_dispatch`.
2. Sets up Java 17 and Flutter 3.24.x stable.
3. Automatically extracts the release version from `pubspec.yaml`.
4. Runs automated test suites.
5. Builds both the release APK (`Postermaker-vX.Y.Z-release.apk`) and App Bundle (`Postermaker-vX.Y.Z-release.aab`).
6. Computes SHA256 checksums and creates a GitHub Release with attached binaries.

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
