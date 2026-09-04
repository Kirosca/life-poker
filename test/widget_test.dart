import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_backjack/main.dart';

void main() {
  testWidgets('Life-Backjack app loads correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifeBackjackApp());

    // Verify that the title is displayed
    expect(find.text('Life-Backjack'), findsOneWidget);

    // Verify that the Hit and Stand buttons are present
    expect(find.text('Hit (抽卡加任务)'), findsOneWidget);
    expect(find.text('Stand (停牌锁定)'), findsOneWidget);

    // Verify FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
