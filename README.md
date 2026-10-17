# Infinite Image Gallery

A clean Flutter image gallery application with infinite scrolling, local favorites, pinch-to-zoom image details, and direct gallery downloads.

## API Selection
For this assignment, I chose the **Picsum Photos API** (`https://picsum.photos`).
- **Zero API Key Requirement:** Does not require registering for an API key or setting environment variables.
- **Reliable Public REST API:** Provides high-resolution photography with pagination (`/v2/list?page=1&limit=20`), image dimensions, and author attribution.
- **Evaluation-Ready:** Any reviewer can clone and run `flutter run` immediately without setup hurdles.

---

## Features
- **Responsive Gallery Grid:** Two-column grid with smooth image loading and progressive caching (`cached_network_image`).
- **Infinite Scrolling:** Auto-loads the next page of images as you scroll near the bottom of the list.
- **Search & Pull-to-Refresh:** Quick author search from the AppBar and pull-to-refresh to reload the latest photos.
- **Detail Screen:**
  - Hero transition animation.
  - Pinch-to-zoom and double-tap zoom via `InteractiveViewer`.
  - Author and image dimensions metadata.
  - Native share sheet (`share_plus`).
  - Save image directly to device photo gallery (`gal` with Android 13+ MediaStore support).
- **Favorites System:**
  - Save/unsave photos with the heart icon.
  - Dedicated Favorites screen with offline viewing and count badge.
  - Local persistence using `SharedPreferences`.
- **Theme Support:** Instant Dark Mode and Light Mode toggle, remembered across app restarts.

---

## Project Structure
```
lib/
├── models/
│   └── photo.dart               # Photo data model with fromJson / toJson
├── services/
│   ├── api_service.dart         # Dio HTTP client for Picsum API
│   └── storage_service.dart     # SharedPreferences storage for favorites & theme
├── providers/
│   ├── gallery_provider.dart    # Riverpod Notifier for gallery state & pagination
│   ├── favorites_provider.dart  # Riverpod Notifier for favorite photos
│   └── theme_provider.dart      # Riverpod Notifier for theme mode
├── screens/
│   ├── home_screen.dart         # Main screen with tabs, search, and infinite grid
│   ├── detail_screen.dart       # High-res photo detail, zoom, and download
│   └── favorites_screen.dart    # Saved favorites list
├── widgets/
│   └── photo_card.dart          # Reusable image card widget
└── main.dart                    # App entry point with ProviderScope
```

---

## State Management
Built with **Flutter Riverpod** (`flutter_riverpod`):
- `GalleryNotifier`: Manages image list, pagination state (`isLoadingMore`, `hasMore`), error handling, and search filtering.
- `FavoritesNotifier`: Manages local favorites list and syncs changes to `SharedPreferences`.
- `ThemeNotifier`: Manages active theme mode (light/dark) with persistence.

---

## How to Run

### 1. Run the App
```bash
flutter pub get
flutter run
```

### 2. Run Tests
```bash
flutter test
```
