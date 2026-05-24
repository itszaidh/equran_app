import 'dart:math';
import 'package:equran/backend/settings_db.dart';

class HifzLimits {
  static const String _maxNewKey = 'hifzMaxNewPerDay';
  static const String _maxReviewKey = 'hifzMaxReviewPerDay';

  static String _todayKey(String prefix) {
    final d = DateTime.now();
    return '${prefix}_${d.year}-${d.month}-${d.day}';
  }

  static SettingsDB get prefsBox => SettingsDB();

  static int get maxNewPerDay =>
      prefsBox.get(_maxNewKey, defaultValue: 10) as int;

  static int get maxReviewPerDay =>
      prefsBox.get(_maxReviewKey, defaultValue: 50) as int;

  static set maxNewPerDay(int v) => prefsBox.put(_maxNewKey, v);

  static set maxReviewPerDay(int v) => prefsBox.put(_maxReviewKey, v);

  static int get todayNewCount =>
      prefsBox.get(_todayKey('hifzNew'), defaultValue: 0) as int;

  // Returns how many new ayahs can still
  // be unlocked today across all units
  static int get remainingNewToday => max(0, maxNewPerDay - todayNewCount);

  static int get todayReviewCount =>
      prefsBox.get(_todayKey('hifzReview'), defaultValue: 0) as int;

  static Future<void> incrementNew() async =>
      prefsBox.put(_todayKey('hifzNew'), todayNewCount + 1);

  static Future<void> incrementReview() async =>
      prefsBox.put(_todayKey('hifzReview'), todayReviewCount + 1);

  static bool get canAddNew => todayNewCount < maxNewPerDay;

  static bool get canReview => todayReviewCount < maxReviewPerDay;
}
