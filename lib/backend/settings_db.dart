import 'package:quran/quran.dart' as quran;
import 'base_db.dart';

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
}
