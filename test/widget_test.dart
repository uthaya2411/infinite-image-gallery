import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/main.dart';
import 'package:infinite_image_gallery/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Renders Home screen with Explore and Favorites tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ImageGalleryApp(),
      ),
    );

    // Initial frame
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AppBar Title and Tabs
    expect(find.text('Image Gallery'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);

    // Switch to Favorites tab
    await tester.tap(find.text('Favorites'));
    await tester.pump(const Duration(milliseconds: 300));

    // Empty state should be visible
    expect(find.text('No Favorites Yet'), findsOneWidget);
  });
}
