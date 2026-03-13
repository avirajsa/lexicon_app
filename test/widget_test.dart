import 'package:flutter_test/flutter_test.dart';
import 'package:lexicon_app/main.dart';

void main() {
  testWidgets('LexiconApp sanity test', (WidgetTester tester) async {
    await tester.pumpWidget(const LexiconApp());
    expect(find.byType(LexiconApp), findsOneWidget);
  });
}
