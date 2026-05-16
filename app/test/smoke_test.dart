import 'package:artifact_reports/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders dashboard with localized header', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ArtifactReportsApp()),
    );
    await tester.pumpAndSettle();
    // EN is the default locale for the test harness.
    expect(find.text('General info'), findsOneWidget);
  });
}
