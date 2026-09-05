import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:life_poker/main.dart';
import 'package:life_poker/screens/blackjack_game_screen.dart';

void main() {
  testWidgets('Comprehensive ancestor and interaction test for Life-Poker', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifePokerApp());
    await tester.pumpAndSettle();

    // 1. Verify title and 6 tabs are displayed
    expect(find.text('Life-Poker'), findsOneWidget);
    expect(find.text('牌桌时间块'), findsOneWidget);
    expect(find.text('事件卡库'), findsOneWidget);
    expect(find.text('技能卡组'), findsOneWidget);
    expect(find.text('金库资产'), findsOneWidget);
    expect(find.text('衣食住行书'), findsOneWidget);
    expect(find.text('21点小游戏'), findsOneWidget);

    // 2. Test 牌桌时间块: Nightly Prep dialog
    await tester.tap(find.text('晚间备战 / 模板'));
    await tester.pumpAndSettle();
    expect(find.text('晚间备战明日 (Nightly Prep)'), findsOneWidget);
    await tester.tap(find.text('稍后调整'));
    await tester.pumpAndSettle();

    // 3. Test 事件卡库: Open add event sheet, verify Slider and Dropdown
    await tester.tap(find.text('事件卡库'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('新增事件卡'));
    await tester.pumpAndSettle();
    expect(find.text('新增事件卡牌 (Event Card)'), findsOneWidget);
    // Dismiss sheet
    Navigator.of(tester.element(find.text('新增事件卡牌 (Event Card)'))).pop();
    await tester.pumpAndSettle();

    // 4. Test 技能卡组: Open add skill sheet
    await tester.tap(find.text('技能卡组'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('解锁技能'));
    await tester.pumpAndSettle();
    expect(find.text('解锁技能手牌 (Skill Card)'), findsOneWidget);
    // Dismiss sheet
    Navigator.of(tester.element(find.text('解锁技能手牌 (Skill Card)'))).pop();
    await tester.pumpAndSettle();

    // 5. Test 金库资产: Open "记一笔"
    await tester.tap(find.text('金库资产'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('记一笔'));
    await tester.pumpAndSettle();
    expect(find.text('记一笔资金流水'), findsOneWidget);
    expect(find.text('日常支出'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    // 6. Test 金库资产: Open "添装备/耗材"
    await tester.tap(find.text('添装备/耗材'));
    await tester.pumpAndSettle();
    expect(find.text('登记新装备 / 补给耗材'), findsOneWidget);
    expect(find.text('🛡️ 固定装备 (资产)'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    // 7. Test 金库资产: Open "更换装配"
    await tester.tap(find.text('更换装配').first);
    await tester.pumpAndSettle();
    expect(find.text('取消'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    // 8. Test 衣食住行书 (Phase 3 Codex Book)
    await tester.tap(find.text('衣食住行书'));
    await tester.pumpAndSettle();
    expect(find.text('衣食住行之书 (Life Codex)'), findsOneWidget);
    expect(find.text('极简胶囊衣橱与穿搭矩阵'), findsOneWidget);
    // Switch to 食之书
    await tester.tap(find.text('食之书'));
    await tester.pumpAndSettle();
    expect(find.text('脑力劳动者低 GI 控糖与进食窗口'), findsOneWidget);
    // Open 编纂新准则 dialog
    await tester.tap(find.text('编纂新准则'));
    await tester.pumpAndSettle();
    expect(find.text('编纂《食之书》新准则'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    // 9. Test 21点小游戏: Play a round
    await tester.tap(find.text('21点小游戏'));
    await tester.pumpAndSettle();
    expect(find.text('Blackjack 21点休闲小游戏'), findsOneWidget);
    expect(find.widgetWithText(ShadButton, '发牌开局 (下注 50 筹码)'), findsOneWidget);
    await tester.tap(find.widgetWithText(ShadButton, '发牌开局 (下注 50 筹码)'));
    await tester.pumpAndSettle();
    expect(find.byType(BlackjackGameScreen), findsOneWidget);
    expect(find.textContaining('筹码:'), findsOneWidget);

    // 10. Phase 4: Test 牌桌时间块 睡眠自律连胜与打卡
    await tester.tap(find.text('牌桌时间块'));
    await tester.pumpAndSettle();
    expect(find.textContaining('睡眠自律连胜'), findsOneWidget);
    await tester.tap(find.text('睡眠早报'));
    await tester.pumpAndSettle();
    expect(find.text('睡眠纪律打卡与评分'), findsOneWidget);
    await tester.tap(find.text('确认打卡 (+40 EXP)'));
    await tester.pumpAndSettle();

    // 11. Phase 4: Test 技能卡组 技能演化派生新牌
    await tester.tap(find.text('技能卡组'));
    await tester.pumpAndSettle();
    expect(find.text('演化派生新牌'), findsOneWidget);
    await tester.tap(find.text('演化派生新牌'));
    await tester.pumpAndSettle();
    expect(find.text('技能演化与专精派生'), findsOneWidget);
    expect(find.textContaining('演化觉醒【全栈跨端大宗师】'), findsOneWidget);
    await tester.tap(find.textContaining('演化觉醒【全栈跨端大宗师】'));
    await tester.pumpAndSettle();
    // Verify the new skill is generated and displayed
    expect(find.text('全栈跨端大宗师'), findsOneWidget);
    expect(find.text('★ 高阶觉醒'), findsOneWidget);
  });
}
