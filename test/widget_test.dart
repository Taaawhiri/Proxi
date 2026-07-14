import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:proxi/main.dart';

void main() {
  testWidgets('login flow leads to the home shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: ProxiApp()));
    await tester.pumpAndSettle();

    expect(find.text('Proxi'), findsOneWidget);
    expect(find.byKey(const Key('submitButton')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('emailField')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
    await tester.tap(find.byKey(const Key('submitButton')));

    // Login is simulated with a network delay.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Nelle vicinanze'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
