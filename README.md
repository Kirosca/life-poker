# ♠️ Life-Poker (人生扑克) - 个人技能与时间块卡牌管理系统

基于 **Flutter** 与 **Material Design 3 (Material You)** 构建的卡牌化个人成长与时间块日程管理应用。

> *"Life is not about holding good cards, but playing a poor hand well."*  
> 人生不在于拿到一手好牌，而在于打好你手中的牌。

---

## 🌟 核心特色 (Core Features)

### 1. 🃏 扑克化技能与手牌体系 (Skill Deck & Hand Management)
- **四大扑克花色领域**：
  - ♠️ **黑桃 (Spades)**：心智 / 技术深度（编程、算法、逻辑推理）
  - ♥️ **红心 (Hearts)**：健康 / 身心活力（运动健身、睡眠恢复、社交连接）
  - ♣️ **梅花 (Clubs)**：认知 / 探索创造（阅读深度、写作表达、艺术灵感）
  - ♦️ **方块 (Diamonds)**：事业 / 生产交付（商业落地、财富管理、日常工作）
- **技能卡成长系统**：每项技能拥有独立的等级 (Level)、经验条 (EXP) 与熟练度，攻克关联任务或专项研习即可获得 EXP 晋升。

### 2. ⏳ 牌桌时间块 (Time-Boxing Slots)
- **时间块即出牌槽位**：将一天划分为若干核心卡槽（如晨间蓄能、上午深度心流、下午高效推进、晚间复盘）。
- **出牌机制 (Play Card)**：从任务卡库中挑选任务卡打入对应时间块槽位，形成今日协同手牌组合。
- **经验联动机制**：在时间块内攻克任务，自动触发关联技能卡牌的经验升级动效。

### 3. ⚡ 21点精力预算机制 (Blackjack Mode - 副功能)
- **精力容量上限 (21 点)**：监控每日打入时间块的所有任务总点数（每张卡牌消耗 1~11 点）。
- **实时四态指示**：
  - 🟢 **Safe (活力充沛)**：槽位点数健康，余量充裕。
  - 🟡 **In the Zone (黄金心流)**：规划在 16~20 点，最佳饱和度。
  - 👑 **Blackjack (完美21点)**：精力与任务分配达到巅峰黄金比例。
  - 🔴 **Bust (精力超载警报)**：点数超过 21 点，提醒精简任务、避免精神内耗。
- **抽卡加任务 (Hit)**：精力富余时，一键从微习惯牌堆抽取健康微任务。
- **停牌锁定 (Stand)**：一键锁定今日牌桌出牌，开启沉浸专注。

---

## 📱 应用架构 (Architecture)

```
lib/
├── main.dart                  # 应用入口与明暗主题管理
├── models/
│   └── poker_card.dart        # CardSuit, SkillCard, TaskCard, TimeBlock 核心扑克数据模型
├── theme/
│   └── app_theme.dart         # Material 3 主题系统 (Light & Dark)
├── widgets/
│   ├── blackjack_meter.dart   # 21点精力预算监控器 (副功能)
│   ├── skill_card_widget.dart # 拟真扑克技能卡牌组件 (带经验条与研习按钮)
│   └── time_block_slot.dart   # 时间块牌桌卡槽与出牌交互组件
└── screens/
    ├── main_poker_app.dart    # 主框架 (NavigationBar 四大导航模块)
    ├── poker_table_screen.dart # 牌桌主日程视图
    ├── task_deck_screen.dart  # 任务卡库 (筛选、出牌、新增、多花色)
    └── skill_deck_screen.dart # 技能卡组 (技能等级、研习升级、花色过滤)
```

---

## 🚀 本地运行 (Getting Started)

```bash
# 获取依赖
flutter pub get

# 启动运行（跨平台支持：Windows 桌面、Web、Android、iOS）
flutter run

# 运行静态分析与单元测试
flutter analyze
flutter test
```

---

## 📄 开源许可证
本项目遵循 [MIT License](LICENSE) 开源协议。
