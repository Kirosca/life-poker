import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/poker_card.dart';

class StorageService {
  static const String _keySkills = 'life_poker_skills';
  static const String _keySleep = 'life_poker_sleep_state';
  static const String _keyCash = 'life_poker_cash_balance';

  static Future<void> saveSkills(List<SkillCard> skills) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = skills.map((s) {
        return {
          'id': s.id,
          'name': s.name,
          'suitIndex': s.suit.index,
          'level': s.level,
          'exp': s.exp,
          'maxExp': s.maxExp,
          'description': s.description,
          'isSleepSkill': s.isSleepSkill,
          'sleepDisciplineScore': s.sleepDisciplineScore,
          'parentTag': s.parentTag,
          'equippedAssetIds': s.equippedAssetIds,
          'evolvedFromSkillId': s.evolvedFromSkillId,
          'buffDescription': s.buffDescription,
          'evolutionOptions': s.evolutionOptions.map((o) => {
            'id': o.id,
            'name': o.name,
            'description': o.description,
            'suitIndex': o.suit.index,
            'requiredParentLevel': o.requiredParentLevel,
            'buffDescription': o.buffDescription,
          }).toList(),
        };
      }).toList();
      await prefs.setString(_keySkills, jsonEncode(jsonList));
    } catch (_) {}
  }

  static Future<List<SkillCard>?> loadSkills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keySkills);
      if (str == null) return null;
      final jsonList = jsonDecode(str) as List<dynamic>;
      return jsonList.map((item) {
        final m = item as Map<String, dynamic>;
        final suit = CardSuit.values[(m['suitIndex'] as int?) ?? 0];
        final evoList = ((m['evolutionOptions'] as List<dynamic>?) ?? []).map((o) {
          final om = o as Map<String, dynamic>;
          return SkillEvolutionOption(
            id: om['id'] as String,
            name: om['name'] as String,
            description: om['description'] as String,
            suit: CardSuit.values[(om['suitIndex'] as int?) ?? suit.index],
            requiredParentLevel: (om['requiredParentLevel'] as int?) ?? 3,
            buffDescription: om['buffDescription'] as String? ?? '',
          );
        }).toList();

        return SkillCard(
          id: m['id'] as String,
          name: m['name'] as String,
          suit: suit,
          level: (m['level'] as int?) ?? 1,
          exp: (m['exp'] as int?) ?? 0,
          maxExp: m['maxExp'] as int?,
          description: (m['description'] as String?) ?? '',
          isSleepSkill: (m['isSleepSkill'] as bool?) ?? false,
          sleepDisciplineScore: (m['sleepDisciplineScore'] as int?) ?? 90,
          parentTag: m['parentTag'] as String?,
          equippedAssetIds: ((m['equippedAssetIds'] as List<dynamic>?) ?? []).cast<String>(),
          evolvedFromSkillId: m['evolvedFromSkillId'] as String?,
          buffDescription: m['buffDescription'] as String?,
          evolutionOptions: evoList,
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSleepState(SleepDisciplineState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'streakDays': state.streakDays,
        'disciplineScore': state.disciplineScore,
        'isNextDayBoostActive': state.isNextDayBoostActive,
        'lastSettlementDate': state.lastSettlementDate?.toIso8601String(),
      };
      await prefs.setString(_keySleep, jsonEncode(data));
    } catch (_) {}
  }

  static Future<SleepDisciplineState?> loadSleepState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keySleep);
      if (str == null) return null;
      final m = jsonDecode(str) as Map<String, dynamic>;
      return SleepDisciplineState(
        streakDays: (m['streakDays'] as int?) ?? 3,
        disciplineScore: (m['disciplineScore'] as int?) ?? 92,
        isNextDayBoostActive: (m['isNextDayBoostActive'] as bool?) ?? true,
        lastSettlementDate: m['lastSettlementDate'] != null
            ? DateTime.tryParse(m['lastSettlementDate'] as String)
            : null,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCashBalance(double balance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyCash, balance);
    } catch (_) {}
  }

  static Future<double?> loadCashBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_keyCash);
    } catch (_) {
      return null;
    }
  }
}
