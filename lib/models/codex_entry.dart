import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum CodexDomain {
  clothing('衣之书', LucideIcons.shirt, Color(0xFFEC4899), '穿搭矩阵 · 材质护理 · 断舍离'),
  food('食之书', LucideIcons.utensils, Color(0xFFF97316), '营养准则 · 自烹食谱 · 预算控制'),
  housing('住之书', LucideIcons.home, Color(0xFF10B981), '工位生产力 · 环境控制 · 保洁SOP'),
  travel('行之书', LucideIcons.compass, Color(0xFF3B82F6), '通勤策略 · 差旅打包 · 运动路线');

  final String title;
  final IconData icon;
  final Color color;
  final String description;
  const CodexDomain(this.title, this.icon, this.color, this.description);
}

enum RuleLevel {
  iron('硬性铁律', Color(0xFFEF4444), LucideIcons.shieldAlert),
  sop('执行SOP', Color(0xFFF59E0B), LucideIcons.listOrdered),
  insight('认知笔记', Color(0xFF3B82F6), LucideIcons.bookmark);

  final String label;
  final Color color;
  final IconData icon;
  const RuleLevel(this.label, this.color, this.icon);
}

class CodexEntry {
  final String id;
  final CodexDomain domain;
  final String title;
  final String summary;
  final String content;
  final RuleLevel level;
  final List<String> tags;
  final List<String> checklist;
  final List<bool> checklistChecked;
  final String? relatedSkillId;
  final List<String> relatedAssetIds;
  final DateTime updatedAt;

  CodexEntry({
    required this.id,
    required this.domain,
    required this.title,
    required this.summary,
    required this.content,
    required this.level,
    this.tags = const [],
    this.checklist = const [],
    List<bool>? checklistChecked,
    this.relatedSkillId,
    this.relatedAssetIds = const [],
    DateTime? updatedAt,
  })  : checklistChecked = checklistChecked ?? List.filled(checklist.length, false),
        updatedAt = updatedAt ?? DateTime.now();

  CodexEntry copyWith({
    String? id,
    CodexDomain? domain,
    String? title,
    String? summary,
    String? content,
    RuleLevel? level,
    List<String>? tags,
    List<String>? checklist,
    List<bool>? checklistChecked,
    String? relatedSkillId,
    List<String>? relatedAssetIds,
    DateTime? updatedAt,
  }) {
    return CodexEntry(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      level: level ?? this.level,
      tags: tags ?? this.tags,
      checklist: checklist ?? this.checklist,
      checklistChecked: checklistChecked ?? this.checklistChecked,
      relatedSkillId: relatedSkillId ?? this.relatedSkillId,
      relatedAssetIds: relatedAssetIds ?? this.relatedAssetIds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<CodexEntry> getInitialEntries() {
    return [
      // ----------------- 衣之书 -----------------
      CodexEntry(
        id: 'codex_cloth_1',
        domain: CodexDomain.clothing,
        title: '极简胶囊衣橱与穿搭矩阵',
        summary: '用黑白灰蓝构建高效、无决策内耗的每日穿着体系。',
        content: '原则：所有单品必须能相互自由搭配。\n'
            '1. 工作日通勤：深灰/黑色重磅纯棉 T 恤或纯色衬衫 + 弹性修身西裤 + 极简德训鞋。\n'
            '2. 深度开发/居家：透气纯棉宽松体恤 + 运动抽绳长裤。\n'
            '3. 运动/户外：排汗速干机能衣 + 压缩裤。\n'
            '4. 关键心法：不买“需要为了搭配它而特意买新衣服”的单品。',
        level: RuleLevel.sop,
        tags: ['胶囊衣橱', '穿搭矩阵', '决策极简'],
        checklist: [
          '上衣全部采用黑/白/灰/藏青统一色系',
          '鞋履保持在 3 双以内（通勤、运动、备用）',
          '悬挂式收纳，洗净后直接入柜避免折痕',
        ],
        relatedSkillId: null,
        relatedAssetIds: [],
      ),
      CodexEntry(
        id: 'codex_cloth_2',
        domain: CodexDomain.clothing,
        title: '衣物材质精细洗护与防形变准则',
        summary: '羊毛、真丝、科技功能面料的分类清洗铁律。',
        content: '铁律与操作规范：\n'
            '1. 羊毛与羊绒制品：绝对禁止机洗烘干，使用专用中性洗涤剂低温手洗，平铺阴干。\n'
            '2. 重磅纯棉 T 恤：翻面放入洗衣袋中机洗，防领口松垮变荷叶边。\n'
            '3. 机能压胶防水冲锋衣：严禁使用柔顺剂，柔顺剂会堵塞透气微孔破坏防水透湿膜。',
        level: RuleLevel.iron,
        tags: ['材质护理', '保养铁律', '防损耗'],
        checklist: [
          '机洗前深浅色严格物理分开',
          '洗护前必须拉上全部拉链和扣好魔术贴',
          '纯棉领口使用洗衣网袋保护',
        ],
        relatedSkillId: null,
        relatedAssetIds: [],
      ),

      // ----------------- 食之书 -----------------
      CodexEntry(
        id: 'codex_food_1',
        domain: CodexDomain.food,
        title: '脑力劳动者低 GI 控糖与进食窗口',
        summary: '告别饭后昏睡，全天维持高专注力平稳血糖曲线。',
        content: '执行原则：\n'
            '1. 进食顺序铁律：先吃膳食纤维蔬菜 -> 再吃高蛋白质肉蛋 -> 最后吃优质复合碳水。\n'
            '2. 间歇性断食（16+8 窗口）：中午 12:00 ~ 晚上 20:00 进食，上午仅饮用黑咖啡/白开水。\n'
            '3. 控糖红线：绝对避免含糖饮料与油炸快餐，碳水优先选择燕麦、糙米、紫薯。',
        level: RuleLevel.iron,
        tags: ['血糖管理', '抗昏睡', '心流脑力'],
        checklist: [
          '晨间只喝黑咖啡或温开水，保持轻断食状态',
          '午餐严格遵守“菜 -> 肉 -> 碳水”就餐顺序',
          '下午 3 点后绝不摄入高精制糖奶茶或甜点',
        ],
        relatedSkillId: 's3',
        relatedAssetIds: ['c1'],
      ),
      CodexEntry(
        id: 'codex_food_2',
        domain: CodexDomain.food,
        title: '15 分钟高蛋白增肌自烹快手 SOP',
        summary: '兼顾极致时间成本与营养素均衡的标准自烹配方。',
        content: '标准配置（单餐 45g 优质蛋白）：\n'
            '1. 蛋白质：去皮鸡胸肉/三文鱼柳 200g，预先用黑胡椒与海盐腌制。\n'
            '2. 蔬菜：西兰花 150g + 小番茄 10 颗，水开烫 90 秒捞出淋橄榄油。\n'
            '3. 碳水：即食快熟纯燕麦 50g 冲入无糖豆浆或开水，或即食杂粮饭 150g。\n'
            '4. 耗时要求：从下锅到清洗完毕不得超过 15 分钟。',
        level: RuleLevel.sop,
        tags: ['自烹SOP', '快手餐', '时间管理'],
        checklist: [
          '提前在周末分装冷冻 5 份腌制肉料包',
          '水开同时入菜与肉，并行烹饪不空转',
          '烹饪结束趁热冲洗不粘锅，防止油垢凝结',
        ],
        relatedSkillId: null,
        relatedAssetIds: [],
      ),

      // ----------------- 住之书 -----------------
      CodexEntry(
        id: 'codex_house_1',
        domain: CodexDomain.housing,
        title: '顶级生产力工位与线缆隐形规范',
        summary: '桌面整洁度直接映射大脑工作区清晰度。',
        content: '工位搭建准则：\n'
            '1. 桌面可视物极简：除屏幕、键盘、鼠标与水杯外，桌面不得长期堆放任何杂物。\n'
            '2. 人体工学坐姿：屏幕上沿与平视视线齐平，手肘自然下垂呈 90 度放置在工学椅扶手上。\n'
            '3. 线缆全隐形：使用理线槽、魔术贴束线带将所有供电线完全收纳在桌底。',
        level: RuleLevel.iron,
        tags: ['工位设计', '人体工学', '极简桌面'],
        checklist: [
          '每晚关机前执行桌面 60 秒物理清空复位',
          '显示器仰角微调 5 度，颈椎无低头受力感',
          '工学椅腰靠精准贴合腰椎 L3-L5 区域',
        ],
        relatedSkillId: 's1',
        relatedAssetIds: ['a2'],
      ),
      CodexEntry(
        id: 'codex_house_2',
        domain: CodexDomain.housing,
        title: '深度助眠卧室环境与微气候控制',
        summary: '通过光照、温湿度与二氧化碳浓度掌控深睡眠质量。',
        content: '卧室微气候控制标准：\n'
            '1. 黄金睡眠室温：控制在 19℃ ~ 21℃，湿度 45% ~ 55%。\n'
            '2. 极致全黑遮光：使用 100% 全遮光窗帘，杜绝充电器呼吸灯与一切微光污染。\n'
            '3. 通风与新风：睡前开启微风模式或新风系统，确保室内 CO2 浓度低于 800 ppm。\n'
            '4. 睡前 60 分钟严禁携带发光电子屏幕进入卧室床头。',
        level: RuleLevel.iron,
        tags: ['睡眠微气候', '深度睡眠', '环境控制'],
        checklist: [
          '睡前 1 小时关闭顶灯，开启暖色微弱地灯',
          '入睡前开窗换气 10 分钟或开启新风',
          '手机放置在书房充电，严禁带入枕边',
        ],
        relatedSkillId: 's4',
        relatedAssetIds: ['c3'],
      ),

      // ----------------- 行之书 -----------------
      CodexEntry(
        id: 'codex_travel_1',
        domain: CodexDomain.travel,
        title: '3 天 2 晚轻量化差旅极简打包清单 (EDC)',
        summary: '单肩背包一包流，登机无需托运，5分钟快速启程。',
        content: '打包哲学：模块化收纳包，永远固定摆放位置。\n'
            '1. 数码包：GaN 氮化镓多口充电头 + 2米编织快充线 + 磁吸充电宝 + 备用Type-C线。\n'
            '2. 个人洗护包：旅行装电动牙刷 + 分装洗发液 + 防漏分装盒。\n'
            '3. 衣物收纳包：2件免烫换洗衣物 + 2套便携内衣 + 压缩收纳袋。\n'
            '4. 移动工位核心：笔记本电脑 + 降噪耳机，放入快取防震隔层。',
        level: RuleLevel.sop,
        tags: ['差旅SOP', '极简打包', '一包流'],
        checklist: [
          '身份证件与电子登机牌准备完毕',
          '降噪耳机充满电并置于随身快取袋',
          '氮化镓快充头与多合一数据线装入收纳袋',
          '便携药盒准备好常用维C与助眠补剂',
          '确认所有充电宝容量符合民航安检标准(<100Wh)',
        ],
        relatedSkillId: null,
        relatedAssetIds: ['a1', 'a3'],
      ),
      CodexEntry(
        id: 'codex_travel_2',
        domain: CodexDomain.travel,
        title: '日常通勤“第二工作区”心流转化法',
        summary: '将单调的通勤路途转变为每日高质量知识输入与冥想时段。',
        content: '转化策略：\n'
            '1. 物理屏障：戴上主动降噪耳机，开启降噪模式隔绝轨道杂音与人群喧哗。\n'
            '2. 音频输入：固定收听预先离线好的高质量播客（科技/商业/哲学）或专业有声书。\n'
            '3. 步行段心率刺激：从地铁站到目的地的步行段采用快步行走，使心率提升至有氧燃脂区间。',
        level: RuleLevel.insight,
        tags: ['通勤利用', '碎片时间', '认知输入'],
        checklist: [
          '前一晚下载好离线播客单集，防止网络中断',
          '地铁进站前开启降噪耳机抗风噪模式',
          '步行段维持大步快走速度，激活晨间多巴胺',
        ],
        relatedSkillId: 's3',
        relatedAssetIds: ['a3'],
      ),
    ];
  }
}
