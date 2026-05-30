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

  String get monthName => monthNames[hMonth - 1];

  @override
  String toString() => '$hDay $monthName $hYear';
}
