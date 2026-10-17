import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery/main.dart';
import 'package:infinite_image_gallery/models/photo.dart';
import 'package:infinite_image_gallery/providers/favorites_provider.dart';
import 'package:infinite_image_gallery/providers/gallery_provider.dart';
import 'package:infinite_image_gallery/services/api_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;

  setUp(() {
    mockApi = MockApiService();
    when(() => mockApi.getPhotos(page: 1, limit: 20)).thenAnswer(
      (_) async => const [
        Photo(
          id: '1',
          author: 'Alejandro',
          width: 800,
          height: 600,
          url: 'https://example.com/1',
          downloadUrl: 'https://example.com/1/download',
        ),
      ],
    );
  });

  testWidgets('Renders Home screen with Explore and Favorites tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiServiceProvider.overrideWithValue(mockApi),
        ],
        child: const ImageGalleryApp(),
      ),
    );

    // Let microtasks and initial fetch settle
    await tester.pumpAndSettle();

    // Verify AppBar Title and Tabs
    expect(find.text('Image Gallery'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);

    // Verify Category Filter Chips exist
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Nature'), findsOneWidget);

    // Verify Layout Toggle button exists
    expect(find.byTooltip('Toggle Layout'), findsOneWidget);

    // Tap layout toggle
    await tester.tap(find.byTooltip('Toggle Layout'));
    await tester.pumpAndSettle();

    // Switch to Favorites tab
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    // Empty state should be visible
    expect(find.text('No Favorites Yet'), findsOneWidget);
  });
}
