import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_sticker/src/app.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MathStickerApp(),
      ),
    );

    // Verify that the app loads
    expect(find.byType(MathStickerApp), findsOneWidget);
  });
}
