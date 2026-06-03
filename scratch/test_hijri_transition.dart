import 'package:equran/prayer/prayer_models.dart';
import 'package:equran/prayer/prayer_times_service.dart';
import 'package:equran/prayer/prayer_timezone_service.dart';

void main() {
  // Initialize timezone database
  PrayerTimezoneService.ensureDatabaseInitialized();

  const service = PrayerTimesService();
  const location = PrayerLocation(
    latitude: 24.4539, // Abu Dhabi
    longitude: 54.3773,
    label: 'Abu Dhabi',
    mode: PrayerLocationMode.manual,
    countryCode: 'AE',
    timezoneId: 'Asia/Dubai',
  );
  
  const settings = PrayerTimeSettings(
    method: PrayerCalculationMethod.dubai,
  );
  
  // Let's calculate the prayer day for a specific date: June 3, 2026
  final testDate = DateTime(2026, 6, 3, 12, 0); // 12:00 PM
  
  final dayTimes = service.calculateDay(
    date: testDate,
    location: location,
    settings: settings,
  );
  
  final maghribTime = dayTimes.entryFor(PrayerTimeKind.maghrib).time;
  print('Calculated Maghrib for June 3: $maghribTime');
  
  // Before Maghrib: say 5:00 PM (17:00)
  final beforeMaghrib = maghribTime.subtract(const Duration(hours: 2));
  final dateBefore = service.calendarDateForInstant(
    instant: beforeMaghrib,
    location: location,
    settings: settings,
  );
  print('Date before Maghrib ($beforeMaghrib): $dateBefore');
  
  // After Maghrib: say 8:00 PM (20:00)
  final afterMaghrib = maghribTime.add(const Duration(hours: 2));
  final dateAfter = service.calendarDateForInstant(
    instant: afterMaghrib,
    location: location,
    settings: settings,
  );
  print('Date after Maghrib ($afterMaghrib): $dateAfter');
  
  // Check that date shifts exactly by 1 day
  final diff = dateAfter.difference(dateBefore).inDays;
  if (diff == 1) {
    print('SUCCESS: Date shifted exactly by 1 day at Maghrib!');
  } else {
    print('FAILURE: Date difference is $diff days!');
    throw StateError('Hijri day transition at Maghrib failed');
  }
}
