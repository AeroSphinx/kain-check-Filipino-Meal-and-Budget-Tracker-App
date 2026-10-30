import 'package:flutter_test/flutter_test.dart';
import 'package:kain_check/main.dart';

void main() {
  testWidgets('KAIN CHECK app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const KainCheckApp());

    expect(find.text('KAIN CHECK'), findsOneWidget);
    expect(find.text('Ano ang Kakainin?'), findsOneWidget);
  });
}
