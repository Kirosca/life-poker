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

    // Test clicking "记一笔" - Ensure NO RED SCREEN
    await tester.tap(find.text('记一笔'));
    await tester.pumpAndSettle();
    expect(find.text('记一笔资金流水'), findsOneWidget);
    expect(find.text('日常支出'), findsOneWidget);
    // Dismiss
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    // Test clicking "添装备/耗材" - Ensure NO RED SCREEN
    await tester.tap(find.text('添装备/耗材'));
    await tester.pumpAndSettle();
    expect(find.text('登记新装备 / 补给耗材'), findsOneWidget);
    expect(find.text('🛡️ 固定装备 (资产)'), findsOneWidget);
    // Dismiss
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    // Test clicking "更换装配" - Ensure NO RED SCREEN
    await tester.tap(find.text('更换装配').first);
    await tester.pumpAndSettle();
    expect(find.text('取消'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
  });
}
