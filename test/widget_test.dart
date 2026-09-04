import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_blackjack/main.dart';

void main() {
  testWidgets('Life-Blackjack app loads correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifeBlackjackApp());

    // Verify that the title is displayed
    expect(find.text('Life-Blackjack'), findsOneWidget);

    // Verify that the Hit and Stand buttons are present
    expect(find.text('Hit (抽卡加任务)'), findsOneWidget);
    expect(find.text('Stand (停牌锁定)'), findsOneWidget);

    // Verify FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
