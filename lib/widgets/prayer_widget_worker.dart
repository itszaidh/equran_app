import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:workmanager/workmanager.dart';
import 'package:equran/widgets/prayer_widget_service.dart';

const String _prayerWidgetTask = 'prayerWidgetRefresh';

class PrayerWidgetWorker {
  static Future<void> init() async {
    await Workmanager().initialize(_callbackDispatcher);
  }

  static Future<void> scheduleRefresh() async {
    // Hourly refresh for next prayer accuracy
    await Workmanager().registerPeriodicTask(
      '${_prayerWidgetTask}_hourly',
      _prayerWidgetTask,
      frequency: const Duration(hours: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );

    // Daily midnight recalculation
    final now = DateTime.now();
    final midnight = DateTime(
      now.year,
      now.month,
      now.day + 1,
      0,
      5,
    ); // 00:05 next day
    final delay = midnight.difference(now);

    await Workmanager().registerOneOffTask(
      '${_prayerWidgetTask}_midnight',
      _prayerWidgetTask,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _prayerWidgetTask ||
        taskName.startsWith('${_prayerWidgetTask}_')) {
      // REQUIRED: initialize Flutter bindings in background isolate before anything else
      WidgetsFlutterBinding.ensureInitialized();
      await HomeWidget.setAppGroupId('com.app.equran');

      try {
        // Read stored coordinates from prefs
        final latStr = await HomeWidget.getWidgetData<String>('widget_lat');
        final lngStr = await HomeWidget.getWidgetData<String>('widget_lng');
        final methodStr = await HomeWidget.getWidgetData<String>(
          'widget_calc_method',
        );
        final madhabStr = await HomeWidget.getWidgetData<String>(
          'widget_madhab',
        );

        // No coordinates saved yet — skip update
        if (latStr == null || lngStr == null) {
          return Future.value(true);
        }

        final lat = double.tryParse(latStr);
        final lng = double.tryParse(lngStr);
        if (lat == null || lng == null) {
          return Future.value(true);
        }

        // Reconstruct adhan_dart objects
        final coordinates = Coordinates(lat, lng);

        // Map stored method string to calculation parameters
        final params = _parametersFromString(
          methodStr ?? 'muslimWorldLeague',
          madhabStr ?? 'shafi',
        );

        // Calculate for today
        final now = DateTime.now();
        final prayerTimes = PrayerTimes(
          coordinates: coordinates,
          date: now,
          calculationParameters: params,
          precision: true,
        );

        // Determine next prayer
        final nextPrayer = PrayerWidgetService.determineNextPrayer(
          fajr: prayerTimes.fajr,
          dhuhr: prayerTimes.dhuhr,
          asr: prayerTimes.asr,
          maghrib: prayerTimes.maghrib,
          isha: prayerTimes.isha,
        );

        // Format times in 24hr by default for background isolate
        String fmt(DateTime dt) {
          final h = dt.hour.toString().padLeft(2, '0');
          final m = dt.minute.toString().padLeft(2, '0');
          return '$h:$m';
        }

        await PrayerWidgetService.updateWidget(
          fajr: fmt(prayerTimes.fajr),
          dhuhr: fmt(prayerTimes.dhuhr),
          asr: fmt(prayerTimes.asr),
          maghrib: fmt(prayerTimes.maghrib),
          isha: fmt(prayerTimes.isha),
          nextPrayer: nextPrayer,
          locationName: '',
          lastUpdated: fmt(DateTime.now()),
        );

        // Chain the midnight task if this was the midnight run
        if (taskName.endsWith('_midnight')) {
          await PrayerWidgetWorker.scheduleRefresh();
        }
      } catch (e) {
        // Silent fail — widget keeps last data
      }
    }
    return Future.value(true);
  });
}

CalculationParameters _parametersFromString(String method, String madhab) {
  final params = switch (method.toLowerCase()) {
    'moonsightingcommittee' =>
      CalculationMethodParameters.moonsightingCommittee(),
    'northamerica' => CalculationMethodParameters.northAmerica(),
    'karachi' => CalculationMethodParameters.karachi(),
    'ummalqura' => CalculationMethodParameters.ummAlQura(),
    'dubai' => CalculationMethodParameters.dubai(),
    'qatar' => CalculationMethodParameters.qatar(),
    'kuwait' => CalculationMethodParameters.kuwait(),
    'egypt' || 'egyptian' => CalculationMethodParameters.egyptian(),
    'turkey' || 'turkiye' => CalculationMethodParameters.turkiye(),
    'tehran' => CalculationMethodParameters.tehran(),
    _ => CalculationMethodParameters.muslimWorldLeague(),
  };
  params.madhab = madhab.toLowerCase() == 'hanafi'
      ? Madhab.hanafi
      : Madhab.shafi;
  return params;
}
