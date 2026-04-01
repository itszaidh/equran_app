import 'package:quran/quran.dart' as quran;

enum AppReciter {
  arAlafasy(
    code: 'ar.alafasy',
    englishName: 'Alafasy',
    bitrate: 128,
  ),
  arShaatree(
    code: 'ar.shaatree',
    englishName: 'Abu Bakr Ash-Shaatree',
    bitrate: 128,
  ),
  arYasserAlDowsari(
    code: 'ar.yasseraldossari',
    englishName: 'Yasser Al-Dowsari',
    bitrate: 128,
  );

  final String code;
  final String englishName;
  final int bitrate;

  const AppReciter({
    required this.code,
    required this.englishName,
    required this.bitrate,
  });

  static AppReciter fromCode(String? code) {
    return AppReciter.values.firstWhere(
          (r) => r.code == code,
      orElse: () => AppReciter.arAlafasy,
    );
  }

  String surahUrl(int surah) =>
      'https://cdn.islamic.network/quran/audio-surah/$bitrate/$code/$surah.mp3';

  String ayahUrl(int surah, int ayah)
  {
    final String ayahUrl = quran.getAudioURLByVerse(surah, ayah);
    // return ayahUrl.replaceAll("ar.alafasy", code);
    print(ayahUrl);
    return ayahUrl;
  }
}
