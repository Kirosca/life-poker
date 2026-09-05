import 'package:flutter_test/flutter_test.dart';
import 'package:life_poker/main.dart';

void main() {
  testWidgets('Life-Poker app loads correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifePokerApp());

    // Verify title is displayed
    expect(find.text('Life-Poker'), findsOneWidget);

    // Verify Navigation Destinations (including Phase 2 金库资产)
    expect(find.text('牌桌时间块'), findsOneWidget);
    expect(find.text('事件卡库'), findsOneWidget);
    expect(find.text('技能卡组'), findsOneWidget);
    expect(find.text('金库资产'), findsOneWidget);
    expect(find.text('21点小游戏'), findsOneWidget);

    // Switch to 金库资产 Tab
    await tester.tap(find.text('金库资产'));
    await tester.pumpAndSettle();

    // Verify treasury dashboard loaded
    expect(find.text('金库与资产背包'), findsOneWidget);
    expect(find.text('流动资金 (Cash)'), findsOneWidget);
    expect(find.text('资产估值 (Assets)'), findsOneWidget);
  });
}
