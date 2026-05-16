import 'package:artifact_reports/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('skeleton renders placeholder', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ArtifactReportsApp()),
    );
    expect(find.text('Artifact Reports — M1 skeleton'), findsOneWidget);
  });
}
