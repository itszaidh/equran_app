enum AppReciter {
  misharyRashidAlAfasy(
    code: '1',
    englishName: 'Mishary Rashid Al Afasy',
    arabicName: 'مشاري راشد العفاسي',
  ),
  abuBakrAlShatri(
    code: '2',
    englishName: 'Abu Bakr Al Shatri',
    arabicName: 'أبو بكر الشاطري',
  ),
  nasserAlQatami(
    code: '3',
    englishName: 'Nasser Al Qatami',
    arabicName: 'ناصر القطامي',
  ),
  yasserAlDosari(
    code: '4',
    englishName: 'Yasser Al Dosari',
    arabicName: 'ياسر الدوسري',
  ),
  haniArRifai(
    code: '5',
    englishName: 'Hani Ar Rifai',
    arabicName: 'هاني الرفاعي',
  );

  final String code;
  final String englishName;
  final String arabicName;

  const AppReciter({
    required this.code,
    required this.englishName,
    required this.arabicName,
  });

  String displayName({required bool arabic}) =>
      arabic ? arabicName : englishName;

  static const Map<String, String> _legacyCodeMap = <String, String>{
    'ar.alafasy': '1',
    'ar.alafasi': '1',
  };

  static String normalizeCode(String? code) {
    if (code == null || code.isEmpty) {
      return AppReciter.misharyRashidAlAfasy.code;
    }
    return _legacyCodeMap[code] ?? code;
  }

  static AppReciter fromCode(String? code) {
    final String normalizedCode = normalizeCode(code);
    return AppReciter.values.firstWhere(
      (r) => r.code == normalizedCode,
      orElse: () => AppReciter.misharyRashidAlAfasy,
    );
  }
}
