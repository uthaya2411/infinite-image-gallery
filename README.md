# Lumina Gallery — Infinite Image Gallery App
> **Flutter Intermediate Level Interview Assignment**  
> Built for **Gnxtace Technologies**  
> Candidate: **Uthaya** | Framework: **Flutter 3.35.5 (Dart 3.9.2)**

[![Flutter Tests](https://img.shields.io/badge/Flutter%20Tests-100%25%20Passing-brightgreen?style=for-the-badge&logo=flutter)](test/)
[![State Management](https://img.shields.io/badge/State%20Management-Riverpod%202.6-blue?style=for-the-badge)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20Layered-orange?style=for-the-badge)](#architecture--state-management)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20macOS-purple?style=for-the-badge)](#platform-support)

---

## 📱 App Highlights & Visual Overview

**Lumina Gallery** is a production-quality, responsive Flutter infinite image gallery application that consumes the **Pixabay API** (with a zero-configuration curated fallback feed), features **infinite scrolling pagination**, **shimmer skeleton loaders**, **pinch-to-zoom high-res detail inspection**, **local favorites persistence with offline support**, and **direct photo gallery downloads with real-time progress tracking**.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           LUMINA GALLERY                                │
│                                                                         │
│  [🔍 Search photos...]       [🌙 Theme]  [🔑 Pixabay Key]               │
│                                                                         │
│  (✦ All) (🌲 Nature) (🎨 Wallpapers) (🐾 Animals) (🏙️ Architecture)    │
│  ─────────────────────────────────────────────────────────────────────  │
│   ┌───────────────┐  ┌───────────────┐                                  │
│   │ [Image Card]  │  │ [Image Card]  │  ◄ Responsive Staggered          │
│   │  Bailey Z.    │  │  David M.     │    Masonry Grid Layout           │
│   │  👍 3.4k  ❤️   │  │  👍 5.1k  ❤️   │                                  │
│   └───────────────┘  └───────────────┘                                  │
│   ┌───────────────┐  ┌───────────────┐                                  │
│   │ [Image Card]  │  │ [Image Card]  │  ◄ Infinite Scroll               │
│   └───────────────┘  └───────────────┘    Auto-fetch next page           │
│                                                                         │
│  [ 🧭 Explore ]                  [ ❤️ Favorites (3) ]                   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## ✨ Feature Checklist & Requirements Matrix

### 🎯 Core Requirements
- [x] **Gallery Home Screen:** Responsive Staggered Masonry Grid (`flutter_staggered_grid_view`) rendering images with harmonious aspect ratios.
- [x] **Infinite Scroll / Pagination:** Seamless pagination triggered when the user scrolls near the bottom (300px threshold), with duplicate avoidance and debounce protection.
- [x] **Loading States:** Staggered skeleton **Shimmer** placeholders on initial load and sleek bottom loading indicators during pagination.
- [x] **Error Handling:** Graceful state transitions for network timeouts, bad responses (400), rate limiting (429), and empty query states with quick **Retry** action buttons.
- [x] **Image Detail Screen:** Seamless **Hero animation** transition, interactive high-res preview with **pinch-to-zoom and double-tap zoom** via `InteractiveViewer`.
- [x] **Description & Attribution Requirement:** Comprehensive metadata display including photographer avatar, username, verified badge, engagement metrics (views, likes, downloads, comments), technical specs (resolution, file size, format), and interactive tag chips.
- [x] **Download Image:** Direct-to-gallery image saving using `gal` (compatible with modern Android 13+ MediaStore and iOS Photo Library) with runtime permissions and **live progress percentage (0% to 100%)**.
- [x] **Favorites:** Instant favorite toggling from image cards or detail screens.
- [x] **Favorites Screen:** Dedicated tab with counter badge, full offline capability (using cached images), and instant removal.
- [x] **Image Performance:** Progressive image caching via `cached_network_image`. Uses optimized `webformatURL` (640px) thumbnails in the grid and `largeImageURL` (1280px+) in the detail view to prevent memory spikes and maintain 60fps scrolling.

### 🌟 Bonus Features
- [x] **Search with Debounce:** Real-time search with 400ms debounce to minimize unnecessary network calls.
- [x] **Pull-to-Refresh:** Standard Material 3 `RefreshIndicator` on the gallery.
- [x] **12 Category Filters:** Smooth horizontal scrollable chips (Nature, Wallpapers, Animals, Architecture, Travel, Food, Sports, Science, Music, People, Business).
- [x] **Hero Animations:** Shared element transitions between grid cards and full-screen view.
- [x] **Theme System:** Dark Mode & Light Mode toggle with persistence across app restarts.
- [x] **Native Sharing:** Native share sheet integration via `share_plus`.
- [x] **Zero-Configuration Mode:** Automatically falls back to a curated, diverse photography feed when no API key is provided, allowing the interviewer to test the app instantly without any configuration hassle.
- [x] **In-App API Key Configuration:** Dedicated modal dialog to inspect or input a Pixabay API key at runtime.
- [x] **Automated Tests:** 100% passing unit tests for `GalleryNotifier`, `FavoritesNotifier`, and widget tests for the app navigation shell.

---

## 🏛️ Architecture & State Management

The application adheres to **Clean Layered Architecture** with unidirectional data flow powered by **Flutter Riverpod 2.6**:

```
lib/
├── core/
│   ├── config/          # Environment configuration (--dart-define & runtime keys)
│   ├── constants/       # API endpoints, categories, pagination constants
│   ├── network/         # Dio client, interceptors, network exception mapper
│   ├── storage/         # SharedPreferences wrapper for favorites, themes & API key
│   ├── theme/           # Material 3 light/dark design system & ThemeNotifier
│   └── utils/           # Formatters (compact numbers, file size) & Snackbar utils
│
└── features/
    ├── gallery/         # Domain models, remote & mock data sources, GalleryRepository,
    │                    # GalleryNotifier, and Masonry Grid widgets
    ├── favorites/       # FavoritesNotifier (persistent offline storage) & FavoritesScreen
    ├── detail/          # DownloadNotifier (live progress & Gal integration) & DetailScreen
    ├── settings/        # API key configuration dialog
    └── home/            # HomeNavigationScreen (bottom navigation, app bar & search)
```

### Why Riverpod?
1. **Separation of Concerns:** Business logic lives entirely inside `Notifier` classes (`GalleryNotifier`, `FavoritesNotifier`, `DownloadNotifier`), keeping UI widgets purely declarative.
2. **BuildContext Independence:** Providers are testable in isolation using `ProviderContainer` without mocking complex widget trees.
3. **Compile-Time Safety & Zero Provider Soup:** No runtime `ProviderNotFoundException` hazards.
4. **Fine-Grained Selectors:** Widgets use `ref.watch(provider.select(...))` to rebuild only when the specific property they depend on changes, guaranteeing smooth 60fps scrolling.

---

## 🚀 Setup & Execution Instructions

### 1. Prerequisites
- **Flutter SDK:** `>= 3.24.0` (Tested on `3.35.5`, Dart `3.9.2`)
- **Android Emulator / Device:** Android 10+ (Tested on **Pixel 6 API 33**) or iOS Simulator

### 2. Clone & Install Dependencies
```bash
cd "Gnxtace Technologies"
flutter pub get
```

### 3. Run the App

#### Option A: Zero Configuration (Recommended for Quick Testing)
The app runs out-of-the-box with a rich, curated high-resolution feed complete with infinite scroll, categories, search, and downloads:
```bash
flutter run -d emulator-5554
```

#### Option B: With Pixabay API Key (Compile-Time)
Supply your free Pixabay key using `--dart-define`:
```bash
flutter run -d emulator-5554 --dart-define=PIXABAY_API_KEY=YOUR_PIXABAY_KEY
```

#### Option C: With Pixabay API Key (Runtime In-App)
1. Run `flutter run -d emulator-5554`.
2. Tap the **Settings (gear icon)** in the top right of the App Bar.
3. Enter your Pixabay key and tap **Save & Apply**. The app immediately switches to querying live Pixabay endpoints.

---

## 🧪 Running Automated Tests

Run all unit and widget tests:
```bash
flutter test
```

Expected output:
```text
00:02 +4: All tests passed!
```

Run static analysis:
```bash
flutter analyze
```

Expected output:
```text
No issues found!
```

---

## 🔑 Permissions & Security Configuration

- **Android (`AndroidManifest.xml`):**
  - `INTERNET` and `ACCESS_NETWORK_STATE` for network queries.
  - `WRITE_EXTERNAL_STORAGE` (scoped to `maxSdkVersion="28"`) and `READ_EXTERNAL_STORAGE` (`maxSdkVersion="32"`).
  - Uses modern **MediaStore API** via `gal` for Android 13+ (API 33), eliminating obsolete dangerous storage permissions.
- **iOS (`Info.plist`):**
  - `NSPhotoLibraryAddUsageDescription` and `NSPhotoLibraryUsageDescription` configured to allow saving images to the iOS Camera Roll.
- **macOS (`DebugProfile.entitlements`):**
  - `com.apple.security.network.client` enabled for desktop network requests.

---

## 📝 Assumptions, Limitations & Future Scope

### Assumptions:
1. **API Key Availability:** Candidates and interview evaluators may not always have a Pixabay account or active API key at the moment of evaluation. Therefore, the app seamlessly defaults to an authentic curated photography feed while fully supporting live Pixabay API integration with a single toggle.
2. **Download Target:** Image downloads are routed directly to the native device Photo Gallery / Camera Roll using `gal` so saved images are immediately visible in the device's native Photos application.

### Limitations:
1. **Pixabay Rate Limits:** Pixabay imposes a rate limit of 100 requests per 60 minutes for free API keys. The app includes specific 429 error handling and debouncing to prevent throttling.
2. **Image Aspect Ratio Variations:** In the public Pixabay API, some webformat dimensions are estimated; the app clamps aspect ratios between `0.65` and `1.6` to preserve a balanced staggered masonry aesthetic.

### Future Improvements:
- Image cropping and wallpaper setting integration.
- Multi-column masonry adaptation for tablets and foldables.
- Multiple download resolution selector (Preview, Webformat, Original High-Res).

---

## 👨‍💻 Developer & Submission Info
- **Project Name:** Infinite Image Gallery
- **Role:** Intermediate Flutter Developer
- **Target Company:** Gnxtace Technologies
- **Git Repository:** Initialized and commit-ready.
