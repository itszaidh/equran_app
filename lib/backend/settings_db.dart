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
  String get quranScriptStyle =>
      get('quran_script_style', defaultValue: 'uthmani') as String;

  /// Setter for tracking the script style preference key
  Future<void> setQuranScriptStyle(String style) async {
    await put('quran_script_style', style);
    quran.setQuranTextAssetBase('assets/data/quran/text/$style');
    await quran.initializeQuran();
  }
}
