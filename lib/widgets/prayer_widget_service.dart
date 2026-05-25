import 'package:equran/prayer/prayer_models.dart';
import 'package:equran/prayer/prayer_settings_store.dart';
import 'package:equran/prayer/prayer_times_service.dart';
import 'package:home_widget/home_widget.dart';

class PrayerWidgetService {
  static const String _appGroupId = 'com.app.equran';

  // Call once at app startup
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.registerInteractivityCallback(_backgroundCallback);
  }

  static Future<void> saveCoordinates({
    required double latitude,
    required double longitude,
    required String calculationMethod,
    required String madhab,
  }) async {
    await Future.wait([
      HomeWidget.saveWidgetData<String>('widget_lat', latitude.toString()),
      HomeWidget.saveWidgetData<String>('widget_lng', longitude.toString()),
      HomeWidget.saveWidgetData<String>(
        'widget_calc_method',
        calculationMethod,
      ),
      HomeWidget.saveWidgetData<String>('widget_madhab', madhab),
    ]);
  }

  // Recalculates and updates the widget data
  static Future<void> refreshWidget() async {
    final store = PrayerSettingsStore();
    final location = store.getLocation();
    final settings = store.getSettings();
    if (location == null) return;

    final service = const PrayerTimesService();
    final effectiveMethod = service.effectiveMethodFor(
      location: location,
      settings: settings,
    );

    await saveCoordinates(
      latitude: location.latitude,
      longitude: location.longitude,
      calculationMethod: effectiveMethod.name,
      madhab: settings.asrMethod.name,
    );

    final now = DateTime.now();
    final todayDate = service.calendarDateForInstant(
      instant: now,
      location: location,
      settings: settings,
    );
    final today = service.calculateDay(
      date: todayDate,
      location: location,
      settings: settings,
    );
    final tomorrow = service.calculateDay(
      date: DateTime(todayDate.year, todayDate.month, todayDate.day + 1),
      location: location,
      settings: settings,
    );

    final nextPrayer = service.nextPrayer(
      day: today,
      tomorrow: tomorrow,
      now: now,
    );

    final use24hr = settings.use24HourFormat;

    final fajr = today.entryFor(PrayerTimeKind.fajr);
    final dhuhr = today.entryFor(PrayerTimeKind.dhuhr);
    final asr = today.entryFor(PrayerTimeKind.asr);
    final maghrib = today.entryFor(PrayerTimeKind.maghrib);
    final isha = today.entryFor(PrayerTimeKind.isha);

    await updateWidget(
      fajr: formatTime(fajr.time, use24hr),
      dhuhr: formatTime(dhuhr.time, use24hr),
      asr: formatTime(asr.time, use24hr),
      maghrib: formatTime(maghrib.time, use24hr),
      isha: formatTime(isha.time, use24hr),
      nextPrayer: nextPrayer.entry.kind.id,
      locationName: location.displayLabel,
      lastUpdated: formatTime(now, use24hr),
    );
  }

  // Push current prayer times to the widget
  // Call this whenever prayer times are calculated
  // or when the app is foregrounded
  static Future<void> updateWidget({
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
    required String nextPrayer,
    required String locationName,
    required String lastUpdated,
  }) async {
    await Future.wait([
      HomeWidget.saveWidgetData<String>('fajr_time', fajr),
      HomeWidget.saveWidgetData<String>('dhuhr_time', dhuhr),
      HomeWidget.saveWidgetData<String>('asr_time', asr),
      HomeWidget.saveWidgetData<String>('maghrib_time', maghrib),
      HomeWidget.saveWidgetData<String>('isha_time', isha),
      HomeWidget.saveWidgetData<String>('next_prayer', nextPrayer),
      HomeWidget.saveWidgetData<String>('location_name', locationName),
      HomeWidget.saveWidgetData<String>('last_updated', lastUpdated),
    ]);

    // Trigger widgets to redraw
    await HomeWidget.updateWidget(androidName: 'PrayerTimesWidgetReceiver');
  }

  // Determine which prayer comes next
  // Pass in today's prayer DateTime values
  static String determineNextPrayer({
    required DateTime fajr,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
  }) {
    final now = DateTime.now();
    if (now.isBefore(fajr)) return 'fajr';
    if (now.isBefore(dhuhr)) return 'dhuhr';
    if (now.isBefore(asr)) return 'asr';
    if (now.isBefore(maghrib)) return 'maghrib';
    if (now.isBefore(isha)) return 'isha';
    return 'fajr'; // next day's fajr
  }

  // Format DateTime to display time string
  // Respects 12hr/24hr based on device locale
  static String formatTime(DateTime dt, bool use24hr) {
    final local = dt.toLocal();
    if (use24hr) {
      final h = local.hour.toString().padLeft(2, '0');
      final m = local.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else {
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      final period = local.hour < 12 ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }
  }
}

// Background callback for widget interactions
// Must be a top-level function
@pragma('vm:entry-point')
Future<void> _backgroundCallback(Uri? uri) async {
  // Tapping the widget opens the app to Prayer page
  // Navigation is handled by MainActivity
}
