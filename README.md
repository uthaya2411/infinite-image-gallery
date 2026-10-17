# Infinite Image Gallery

A production-grade, 60 FPS Flutter image gallery application featuring infinite scrolling, responsive masonry grid, category filtering, offline favorites persistence, pinch-to-zoom detail view, and direct photo gallery saving.

Developed for the **Gnxtace Technologies Flutter Intermediate Developer Interview**.

---

## 📱 Submission Deliverables

- **Git Repository:** [Local Git Repository / Remote Link]
- **Runnable APK:** [`infinite-image-gallery.apk`](./infinite-image-gallery.apk) (48 MB AOT Release build)
- **Built & Tested On:** Physical Samsung Galaxy M21 (Android 12/13) & Google Pixel 6 (API 33)
- **Test Suite:** `flutter test` (5/5 unit and widget tests passing, 0 analyzer issues)

---

## 📸 Screenshots

| 1. Masonry Grid & Categories | 2. Category Filter (Nature) | 3. High-Res Detail & Zoom | 4. Gallery Save & Offline Favorites |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/samsung_live_screen.png" width="200" /> | <img src="screenshots/category_nature_filtered.png" width="200" /> | <img src="screenshots/08_glass_detail.png" width="200" /> | <img src="screenshots/09_glass_downloaded.png" width="200" /> |

---

## 🎯 Evaluation Criteria Mapping

| Area | Weight | How It Is Addressed in Code | Key Files |
|:---|:---:|:---|:---|
| **Flutter/Dart code quality** | 20% | Strict typing, null-safety, 0 analyzer warnings, immutable models with `const` constructors, and granular repaint boundaries. | [`lib/main.dart`](lib/main.dart), [`lib/widgets/photo_card.dart`](lib/widgets/photo_card.dart) |
| **State management & architecture** | 20% | Built on **Flutter Riverpod** (`Notifier` & `NotifierProvider`). Clean separation of concerns (Models, Services, Providers, Screens, Widgets) with zero AI bloat. Granular selectors (`ref.watch(favoritesProvider.select(...))`) prevent unnecessary widget rebuilds. | [`lib/providers/gallery_provider.dart`](lib/providers/gallery_provider.dart), [`lib/providers/favorites_provider.dart`](lib/providers/favorites_provider.dart) |
| **API integration & pagination** | 20% | Robust `Dio` client consuming Picsum Photos REST API with pagination (`page` & `limit`), scroll debounce, timeout handling, error mapping, and pull-to-refresh. | [`lib/services/api_service.dart`](lib/services/api_service.dart), [`lib/providers/gallery_provider.dart`](lib/providers/gallery_provider.dart) |
| **UI/UX & responsiveness** | 15% | Elegant glassmorphism styling, layout toggle between **Masonry Grid** and **Standard 2-Column Grid**, horizontal category chips, Hero animations, and pinch-to-zoom with double-tap reset. | [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart), [`lib/screens/detail_screen.dart`](lib/screens/detail_screen.dart) |
| **Favorites / local persistence** | 10% | Instant toggle from grid and detail views. Automatically serialized to JSON and persisted locally via `SharedPreferences`. Accessible offline on dedicated Favorites screen. | [`lib/services/storage_service.dart`](lib/services/storage_service.dart), [`lib/screens/favorites_screen.dart`](lib/screens/favorites_screen.dart) |
| **Download / error / permissions** | 10% | Direct image download with live percentage progress (`Saving X%`), Android 13+ MediaStore permissions via `gal`, retry views for network errors, and non-crashing fallback image widgets. | [`lib/screens/detail_screen.dart`](lib/screens/detail_screen.dart) |
| **Testing & documentation** | 5% | 5/5 unit and widget tests covering pagination, search, category filtering, layout toggle, and navigation. Complete README and setup guide. | [`test/unit/`](test/unit/), [`test/widget_test.dart`](test/widget_test.dart) |

---

## 🏛️ Architecture & State Management

The application follows a clean, natural **Unidirectional Data Flow (UDF)** powered by **Flutter Riverpod**:

```
UI Layer (Screens & Widgets)
       ▲               │
       │ (State)       │ (User Action / Intent)
       │               ▼
State Layer (Riverpod Notifiers: Gallery, Favorites, Theme)
       ▲               │
       │ (Data)        │ (Async Request)
       │               ▼
Service Layer (ApiService via Dio & StorageService via SharedPreferences)
```

### Provider Responsibilities:
1. **`galleryProvider` (`GalleryNotifier`):**
   - Manages `photos`, `isLoading`, `isLoadingMore`, `page`, `hasMore`, and `error`.
   - Handles real-time search queries and category filtering (`selectedCategory`).
   - Controls layout state (`isMasonry` toggle).
2. **`favoritesProvider` (`FavoritesNotifier`):**
   - Holds the collection of favorited photos in memory.
   - Syncs changes asynchronously with `SharedPreferences`.
3. **`themeProvider` (`ThemeNotifier`):**
   - Toggles and persists Material 3 Light/Dark mode.

---

## 🌐 API Selection & Configuration

### Why Picsum Photos API?
The assignment allows legally suitable free public image APIs. **Picsum Photos API** (`https://picsum.photos`) was selected:
- **Zero API Key Requirement:** Reviewers can immediately run `flutter run` without registering accounts or configuring API keys.
- **Stable Pagination:** Native query parameters (`/v2/list?page=1&limit=20`) with high-resolution photography and author credits.
- **Exact Aspect Ratios:** Dynamic dimension formatting (`/id/$id/360/480`) matching the app's 3:4 portrait card aspect ratio for instant downloading and 60 FPS decoding.

### Optional: Switching to Pixabay API
If you prefer Pixabay, an API key can be plugged directly into `lib/services/api_service.dart`:
```dart
// To switch to Pixabay:
const String pixabayApiKey = 'YOUR_PIXABAY_API_KEY';
final response = await _dio.get(
  'https://pixabay.com/api/',
  queryParameters: {
    'key': pixabayApiKey,
    'page': page,
    'per_page': limit,
    'image_type': 'photo',
  },
);
```

---

## ⚡ 60 FPS Performance Optimizations

To ensure steady 60 FPS scrolling on mobile devices:
1. **Decoded Memory Capping:** Configured `memCacheWidth: 360` and `memCacheHeight: 480` in `CachedNetworkImage`. Prevents the rasterizer from decoding raw 5000px bitmaps into RAM.
2. **Zero-Blur Glass Floating Bar:** Replaced continuous `BackdropFilter` passes over scrolling pixels with a hardware-accelerated frosted glass container (tinted surface + ambient drop shadow + 1.2px refraction border). Eliminates raster cache invalidations.
3. **Granular Riverpod Selectors:** Individual `PhotoCard` widgets watch only their own favorite state using `ref.watch(favoritesProvider.select(...))`, preventing full-list rebuilds when a photo is favorited.
4. **Repaint Boundaries:** Wrapped each card in a `RepaintBoundary` to isolate layout paints during fling scrolling.
5. **Static Frosted Placeholders:** Replaced animated progress tickers with static frosted placeholders, avoiding CPU/GPU ticker contention while multiple images download concurrently.

---

## 🚀 How to Run the Project

### Prerequisites
- Flutter SDK `^3.9.0`
- Dart SDK `^3.9.0`
- Android Device or Physical Phone connected via USB

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
# Debug mode
flutter run

# Or for optimal 60 FPS performance:
flutter run --release
```

### 3. Run Tests
```bash
# Run unit and widget tests
flutter test

# Verify static analysis (0 errors, 0 warnings)
flutter analyze
```

---

## 📦 Deliverable APK

A pre-built, release-optimized AOT APK is provided in the repository root:
- **Path:** [`infinite-image-gallery.apk`](./infinite-image-gallery.apk)
- **Install via ADB:**
  ```bash
  adb install -r infinite-image-gallery.apk
  ```

---

## 📝 Assumptions, Limitations & Future Scope

### Assumptions
1. **Public Network Connectivity:** Picsum Photos API assumes internet connectivity for live paging. If offline, the app displays a clear error state with a `Retry` button, while all previously saved favorites remain accessible offline.
2. **Android 13+ Media Permissions:** The download functionality uses the `gal` package, which complies with Android 13+ granular media permissions (`READ_MEDIA_IMAGES`) without requiring legacy storage permissions.

### Limitations & Future Scope
1. **Offline Image Cache:** Images loaded in the grid are cached in the device disk cache via `cached_network_image`. A complete offline SQL database (e.g. `drift` or `isar`) could be added for pre-fetching entire pages for offline viewing.
2. **Custom Album Categorization:** Downloaded images are currently saved to the main device Pictures folder. Future versions could create a dedicated "Infinite Gallery" custom album.
3. **Advanced Filtering:** Category filters are deterministically mapped to photo tags. In an enterprise version with backend search, full-text multi-facet search could be integrated.
