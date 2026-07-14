import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proxi/main.dart';

void main() {
  testWidgets('ProxiApp boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ProxiApp()));

    expect(find.text('Proxi — Login'), findsOneWidget);
  });
}
