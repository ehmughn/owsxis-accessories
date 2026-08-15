import 'package:flutter_test/flutter_test.dart';
import 'package:owsxi_mobile/main.dart';

void main() {
  testWidgets('Owsxi app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OwsxiMobileApp());
    expect(find.text('OWSXI'), findsWidgets);
  });
}
