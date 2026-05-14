import 'package:flutter_test/flutter_test.dart';
import 'package:cred_app/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CredApp());
    expect(find.text('CRED'), findsAny);
  });
}