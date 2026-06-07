import 'package:quran/quran.dart' as quran;
import 'base_db.dart';
import 'daily_tools_config.dart';

class SettingsDB extends BaseDB {
  // Private constructor
  SettingsDB._privateConstructor() : super('settings');

  // Singleton instance
  static final SettingsDB _instance = SettingsDB._privateConstructor();

  // Factory constructor to return the singleton instance
  factory SettingsDB() {
    return _instance;
  }

  @override
  Future<void> initBox() async {
    await super.initBox();
    final String activeStyle = quranScriptStyle;
    quran.setQuranTextAssetBase('assets/data/quran/text/$activeStyle');
  }

  /// Getter for tracking the script style preference key
  String get quranScriptStyle {
    final String style =
        get('quran_script_style', defaultValue: 'qpc-hafs') as String;
    return style == 'uthmani' ? 'qpc-hafs' : style;
  }

  /// Setter for tracking the script style preference key
  Future<void> setQuranScriptStyle(String style) async {
    final String normalizedStyle = style == 'uthmani' ? 'qpc-hafs' : style;
    await put('quran_script_style', normalizedStyle);
    quran.setQuranTextAssetBase('assets/data/quran/text/$normalizedStyle');
    await quran.initializeQuran();
  }

  /// Get visible daily tools from settings
  List<DailyToolType> getVisibleDailyTools() {
    final List<dynamic>? saved = get('daily_tools_visible') as List<dynamic>?;
    if (saved == null) {
      return List<DailyToolType>.from(DailyToolType.defaultTools);
    }
    return List<DailyToolType>.from(
      saved.map(
        (e) => DailyToolType.values.firstWhere(
          (t) => t.name == e,
          orElse: () => DailyToolType.quran,
        ),
      ),
    );
  }

  /// Save visible daily tools to settings
  Future<void> setVisibleDailyTools(List<DailyToolType> tools) async {
    await put('daily_tools_visible', tools.map((t) => t.name).toList());
  }
}
