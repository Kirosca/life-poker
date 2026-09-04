# ♠️ Life-Blackjack (生命21点) - Flutter Material 3 Todo Demo

基于 **Flutter** 与 **Material Design 3 (Material You)** 打造的高颜值游戏化待办任务管理应用。

---

## 🌟 核心特色 (Key Features)

### 1. 🎨 Material Design 3 现代美学
- **动态色彩与规范**：基于 `ColorScheme.fromSeed` 的动态质感配色，完整适配浅色 (Light) / 深色 (Dark) 主题。
- **现代化组件质感**：采用圆角卡片 (`CardThemeData`)、浮动操作按钮 (`FloatingActionButton.extended`)、过滤标签 (`FilterChip`)、分段按钮 (`SegmentedButton`) 和 Material 3 底部动作抽屉 (`showModalBottomSheet`)。
- **流畅动效与手势交互**：支持左滑侧滑删除 (`Dismissible`)、划线完成动画及撤销 SnackBar。

### 2. 🃏 独特的“生命21点 (Life-Blackjack)”精力管理哲学
- **精力容量上限 (21 点)**：将每天的心智精力设定为 21 点上限。每个待办任务被赋予 1~11 点不同的精力消耗：
  - `1 ~ 3 点`：微习惯与轻量任务（喝水、整理桌面、伸展）
  - `4 ~ 7 点`：日常核心任务（代码设计、运动、阅读）
  - `8 ~ 11 点`：高能攻坚任务（重大发布、深度攻克难题）
- **状态看板 (Blackjack Meter)**：
  - 🟢 **Safe (活力充足)**：精力槽尚有余量，精力充沛。
  - 🟡 **In the Zone (黄金专注)**：规划处于 16~20 点，最佳心流饱和度。
  - 👑 **Blackjack (完美21点)**：精力分配达到巅峰黄金比例。
  - 🔴 **Bust (精力超载)**：超过 21 点警报，提醒用户拒绝内耗，精简任务。
- **抽卡加任务 (Hit)**：精力富余时，一键从微习惯牌堆抽取健康小任务。
- **停牌锁定 (Stand)**：一键锁定今日任务清单，开启沉浸专注模式。

### 3. 🔍 强大的任务组织与统计
- **即时搜索**：支持按任务标题及备注关键字模糊过滤。
- **状态 & 分类过滤**：全部 / 未完成 / 已完成，支持工作、生活、学习、健康、休闲等分类标签。
- **精力看板与数据统计**：可视化展示待办总数、完成率、各分类占比以及已消耗的精力点数。

---

## 📱 核心架构 (Project Architecture)

```
lib/
├── main.dart                  # 应用入口与明暗主题切换管理
├── models/
│   └── todo_item.dart         # TodoItem 数据模型、优先级与分类枚举
├── theme/
│   └── app_theme.dart         # Material 3 主题配置 (Light & Dark)
├── widgets/
│   ├── blackjack_meter.dart   # 21点精力可视化看板与 Hit/Stand 交互
│   └── todo_card.dart         # Material 3 任务卡片与侧滑手势组件
└── screens/
    ├── todo_home_screen.dart  # 主页面 (搜索、筛选、牌桌看板、列表)
    ├── add_edit_todo_sheet.dart # 新增/编辑任务底部抽屉表单
    └── stats_dialog.dart      # 数据统计与精力分析弹窗
```

---

## 🚀 运行与构建 (Getting Started)

### 环境依赖
- **Flutter SDK**: `>= 3.13.0`
- **Dart SDK**: `>= 3.13.0`

### 本地启动
```bash
# 获取依赖
flutter pub get

# 启动运行（支持 Windows 桌面、Web、Android、iOS）
flutter run

# 运行静态分析与单元测试
flutter analyze
flutter test
```

---

## 🌐 推送至 GitHub (Push to GitHub)

若您要在 GitHub 上管理本项目，只需按以下步骤执行：

1. 在 GitHub 上新建一个名为 `life-blackjack` 的空仓库：  
   `https://github.com/Kirosca/life-blackjack`
2. 在终端执行推送命令：
   ```bash
   git branch -M main
   git remote add origin https://github.com/Kirosca/life-blackjack.git
   git push -u origin main
   ```

---

## 📄 开源许可证
本项目遵循 [MIT License](LICENSE) 开源协议。
