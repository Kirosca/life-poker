import 'package:flutter_test/flutter_test.dart';
import 'package:life_poker/main.dart';

void main() {
  testWidgets('Life-Poker app loads correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifePokerApp());

    // Verify title is displayed
    expect(find.text('Life-Poker'), findsOneWidget);

    // Verify Navigation Destinations
    expect(find.text('牌桌时间块'), findsOneWidget);
    expect(find.text('事件卡库'), findsOneWidget);
    expect(find.text('技能卡组'), findsOneWidget);
    expect(find.text('21点小游戏'), findsOneWidget);
  });
}
