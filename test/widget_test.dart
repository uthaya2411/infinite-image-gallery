import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/core/storage/local_storage_service.dart';
import 'package:infinite_image_gallery/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders HomeNavigationScreen with Explore and Favorites tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const InfiniteGalleryApp(),
      ),
    );

    // Pump frames to render widgets (Shimmer runs continuously, so we use pump with duration)
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Title and Navigation Tabs
    expect(find.text('Lumina Gallery'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);

    // Verify Category Filter Chips are present
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);

    // Tap on Favorites tab
    await tester.tap(find.text('Favorites'));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify empty favorites view is displayed
    expect(find.text('No Favorites Yet'), findsOneWidget);
  });
}
