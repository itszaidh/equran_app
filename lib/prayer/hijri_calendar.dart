/// Approximate Hijri (Islamic) calendar date converted from Gregorian.
/// Uses a standard Meeus/Julian Day algorithm. Results are very close
/// for most practical purposes but should be treated as approximate.
/// Sighting offset allows manual adjustment for local moon sighting.
class HijriCalendar {
  HijriCalendar.fromDate(DateTime date, {int offset = 0}) {
    // Add manual sighting offset in days
    final DateTime adjustedDate = date.add(Duration(days: offset));

    int year = adjustedDate.year;
    int month = adjustedDate.month;
    int day = adjustedDate.day;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    final int a = (year / 100).floor();
    final int b = (a / 4).floor();
    final int c = 2 - a + b;
    final int e = (365.25 * (year + 4716)).floor();
    final int f = (30.6001 * (month + 1)).floor();
    final double jd = c + day + e + f - 1524.5;

    // Convert Julian Day to Hijri using standard Meeus formula
    final int jdInt = (jd + 0.5).floor();
    final int l = jdInt - 1948440 + 10632;
    final int n = (l - 1) ~/ 10631;
    final int remainderL = l - 10631 * n + 354;

    final int j =
        ((10985 - remainderL) ~/ 5316) * ((50 * remainderL) ~/ 17719) +
        (remainderL ~/ 5670) * ((43 * remainderL) ~/ 15238);

    final int finalL =
        remainderL -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;

    hMonth = (24 * finalL) ~/ 709;
    hDay = finalL - (709 * hMonth) ~/ 24;
    hYear = 30 * n + j - 30;
  }

  late final int hYear;
  late final int hMonth;
  late final int hDay;

  // English month names (existing, kept for compatibility)
  static const List<String> monthNames = <String>[
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qa\'dah',
    'Dhu al-Hijjah',
  ];

  // Arabic script month names (for beautiful UI display)
  static const List<String> monthNamesArabic = <String>[
    'مُحَرَّم',
    'صَفَر',
    'رَبِيع الأَوَّل',
    'رَبِيع الثَّانِي',
    'جُمَادَى الأُولَىٰ',
    'جُمَادَى الآخِرَة',
    'رَجَب',
    'شَعْبَان',
    'رَمَضَان',
    'شَوَّال',
    'ذُو القَعْدَة',
    'ذُو الحِجَّة',
  ];

  static const List<String> _monthNamesTurkish = <String>[
    'Muharrem',
    'Safer',
    'Rebiülevvel',
    'Rebiülahir',
    'Cemaziyelevvel',
    'Cemaziyelahir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  static const List<String> _monthNamesIndonesian = <String>[
    'Muharram',
    'Safar',
    'Rabi\'ul Awwal',
    'Rabi\'ul Akhir',
    'Jumadil Awwal',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadan',
    'Syawwal',
    'Dzulqa\'dah',
    'Dzulhijjah',
  ];

  static const List<String> _monthNamesBengali = <String>[
    'মুহাররম',
    'সফর',
    'রবিউল আউয়াল',
    'রবিউস সানি',
    'জমাদিউল আউয়াল',
    'জমাদিউস সানি',
    'রজব',
    'শাবান',
    'রমজান',
    'শাওয়াল',
    'জিলকদ',
    'জিলহজ',
  ];

  static const List<String> _monthNamesGerman = <String>[
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' ath-Thani',
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qa\'dah',
    'Dhu al-Hijjah',
  ];

  static const List<String> _monthNamesUrdu = <String>[
    'محرم',
    'صفر',
    'ربیع الاول',
    'ربیع الثانی',
    'جمادی الاول',
    'جمادی الثانی',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذوالقعدہ',
    'ذوالحجہ',
  ];

  static const List<String> _monthNamesFarsi = <String>[
    'محرم',
    'صفر',
    'ربیع‌الاول',
    'ربیع‌الثانی',
    'جمادی‌الاول',
    'جمادی‌الثانی',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذی‌القعده',
    'ذی‌الحجه',
  ];

  String get monthName => monthNames[hMonth - 1];
  String get monthNameArabic => monthNamesArabic[hMonth - 1];

  /// Get the localized month name according to the provided language code.
  String getLocalizedMonthName(String lang) {
    final String langCode = lang.split('_').first.toLowerCase();
    switch (langCode) {
      case 'tr':
        return _monthNamesTurkish[hMonth - 1];
      case 'id':
        return _monthNamesIndonesian[hMonth - 1];
      case 'bn':
        return _monthNamesBengali[hMonth - 1];
      case 'de':
        return _monthNamesGerman[hMonth - 1];
      case 'ur':
        return _monthNamesUrdu[hMonth - 1];
      case 'fa':
        return _monthNamesFarsi[hMonth - 1];
      case 'ar':
        return monthNamesArabic[hMonth - 1];
      default:
        return monthName;
    }
  }

  /// Short "D Month Y" representation (English)
  @override
  String toString() => '$hDay $monthName $hYear';

  /// Beautiful Arabic representation
  String toArabicString() => '$hDay $monthNameArabic $hYear';

  /// Format as localized date string
  String toLocalizedDateString(String lang) {
    return '$hDay ${getLocalizedMonthName(lang)} $hYear';
  }

  // ==================== Islamic Event Helpers (for UI) ====================

  /// Returns true for days traditionally recommended for fasting (widely observed).
  bool get isRecommendedFastingDay {
    if (hMonth == 9) return true; // Ramadan
    if (hMonth == 12 && hDay == 9) return true; // Arafah
    if (hMonth == 1 && (hDay == 9 || hDay == 10)) return true; // Ashura / Tasua
    if (hDay == 13 || hDay == 14 || hDay == 15) return true; // Ayyam al-Bid
    return false;
  }

  /// Returns a short, beautiful English label for major blessed events (or null).
  String? get majorOccasion {
    if (hMonth == 9) {
      if (hDay == 1) return 'First Day of Ramadan';
      if (<int>[21, 23, 25, 27, 29].contains(hDay)) {
        return 'Laylat al-Qadr';
      }
      return 'Ramadan';
    }
    if (hMonth == 10 && hDay == 1) return 'Eid al-Fitr';
    if (hMonth == 12 && hDay == 9) return 'Day of Arafah';
    if (hMonth == 12 && hDay == 10) return 'Eid al-Adha';
    if (hMonth == 1 && hDay == 1) return 'Islamic New Year';
    if (hMonth == 1 && hDay == 10) return 'Day of Ashura';
    if (hMonth == 8 && hDay == 15) return 'Shab-e-Barat';
    if (hMonth == 7 && hDay == 27) return 'Isra\' and Mi\'raj';
    return null;
  }

  /// Returns a short label suitable for small calendar badges.
  String? get shortEventLabel {
    final occasion = majorOccasion;
    if (occasion != null) return occasion;
    if (isRecommendedFastingDay) return 'Fast';
    return null;
  }

  /// Very rough moon phase estimate (0=new, 1=waxing crescent, 2=full-ish, 3=waning).
  /// Good enough for beautiful UI indicators. Not astronomically precise.
  int get estimatedMoonPhase {
    // Rough approximation based on lunar month position
    if (hDay <= 2 || hDay >= 28) return 0; // New moon / very thin crescent
    if (hDay < 8) return 1; // Waxing crescent
    if (hDay < 15) return 1; // First quarter to waxing gibbous
    if (hDay < 18) return 2; // Near full
    if (hDay < 23) return 3; // Waning
    return 3;
  }

  /// Human friendly moon phase name for details view.
  String get moonPhaseName {
    switch (estimatedMoonPhase) {
      case 0:
        return 'New Moon';
      case 1:
        return 'Waxing Crescent';
      case 2:
        return 'Full Moon';
      case 3:
        return 'Waning Crescent';
      default:
        return 'Crescent';
    }
  }
}
