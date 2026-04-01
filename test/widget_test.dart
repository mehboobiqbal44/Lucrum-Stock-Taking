import 'package:flutter_test/flutter_test.dart';
import 'package:lucrum_stock_taking/app.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LucrumStockTaking());
    await tester.pumpAndSettle();

    expect(find.text('Lucrum Stock Taking'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
