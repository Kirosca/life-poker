import 'package:flutter_test/flutter_test.dart';
import 'package:life_poker/main.dart';

void main() {
  testWidgets('Life-Poker app loads correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifePokerApp());

    // Verify title is displayed
    expect(find.text('Life-Poker'), findsOneWidget);

    // Verify Poker Table & Time blocks
    expect(find.text('牌桌时间块'), findsOneWidget);
    expect(find.text('任务卡库'), findsOneWidget);
    expect(find.text('技能卡组'), findsOneWidget);
    expect(find.text('21点精力'), findsOneWidget);

    // Verify Hit and Stand buttons on the table
    expect(find.text('Hit (抽卡加任务)'), findsOneWidget);
    expect(find.text('Stand (停牌锁定)'), findsOneWidget);
  });
}
