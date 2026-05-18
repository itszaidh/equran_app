import 'dart:async';

import 'package:equran/backend/settings_db.dart';
import 'package:equran/prayer/manual_prayer_location_page.dart';
import 'package:equran/prayer/prayer_map_location_page.dart';
import 'package:equran/prayer/prayer_location_service.dart';
import 'package:equran/prayer/prayer_hero_card.dart';
import 'package:equran/prayer/prayer_models.dart';
import 'package:equran/prayer/prayer_notification_service.dart';
import 'package:equran/prayer/prayer_settings_store.dart';
import 'package:equran/prayer/prayer_time_thumb_card.dart';
import 'package:equran/prayer/prayer_times_settings_page.dart';
import 'package:equran/prayer/prayer_times_service.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({
    super.key,
    this.enableLiveCountdown = true,
    this.initialNow,
    this.mapLocationPicker,
    this.locationService,
    this.notificationService,
  });

  final bool enableLiveCountdown;
  final DateTime? initialNow;
  final PrayerLocationPicker? mapLocationPicker;
  final PrayerLocationService? locationService;
  final PrayerNotificationService? notificationService;

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  final PrayerTimesService _service = const PrayerTimesService();
  final PrayerSettingsStore _store = PrayerSettingsStore();
  late final PrayerLocationService _locationService;
  late final PrayerNotificationService _notificationService;
  Timer? _timer;
  late DateTime _now;
  DateTime? _selectedDate;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? const PrayerLocationService();
    _notificationService =
        widget.notificationService ?? PrayerNotificationService();
    _now = widget.initialNow ?? DateTime.now();
    unawaited(_refreshCurrentDeviceLocationOnEntry());
    if (widget.enableLiveCountdown) {
      _scheduleNextRefresh();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ValueListenableBuilder(
        valueListenable: SettingsDB().listener,
        builder: (BuildContext context, Object? value, Widget? child) {
          final PrayerLocation? location = _store.getLocation();
          final PrayerTimeSettings settings = _store.getSettings();
          if (location == null) {
            return _buildSetupState(context);
          }

          final DateTime todayDate = _service.calendarDateForInstant(
            instant: _now,
            location: location,
            settings: settings,
          );
          final PrayerDay today = _service.calculateDay(
            date: todayDate,
            location: location,
            settings: settings,
          );
          final DateTime selectedDate = _selectedDate ?? todayDate;
          final bool isViewingToday = _isSameCalendarDate(
            selectedDate,
            todayDate,
          );
          final PrayerDay selectedDay = isViewingToday
              ? today
              : _service.calculateDay(
                  date: selectedDate,
                  location: location,
                  settings: settings,
                );
          final PrayerDay nextSelectedDay = _service.calculateDay(
            date: DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day + 1,
            ),
            location: location,
            settings: settings,
          );
          final _PrayerHeroTiming heroTiming;
          final PrayerTimeKind? highlightedPrayer;
          PrayerTimeEntry? heroCurrentPrayer;
          String? heroTitleOverride;
          String? heroSubtitleOverride;
          if (isViewingToday) {
            final PrayerDay yesterday = _service.calculateDay(
              date: DateTime(
                todayDate.year,
                todayDate.month,
                todayDate.day - 1,
              ),
              location: location,
              settings: settings,
            );
            final PrayerDay tomorrow = _service.calculateDay(
              date: DateTime(
                todayDate.year,
                todayDate.month,
                todayDate.day + 1,
              ),
              location: location,
              settings: settings,
            );
            final NextPrayer nextPrayer = _service.nextPrayer(
              day: today,
              tomorrow: tomorrow,
              now: _now,
            );
            heroTiming = _heroTimingFor(nextPrayer);
            final PrayerCurrentPeriod currentPeriod = _service
                .currentPrayerPeriod(
                  today: today,
                  yesterday: yesterday,
                  now: _now,
                );
            highlightedPrayer = currentPeriod.highlightedKind;
            heroCurrentPrayer = currentPeriod.currentPrayer;
            heroTitleOverride = _heroTitleOverrideFor(currentPeriod);
            heroSubtitleOverride = _heroSubtitleOverrideFor(
              currentPeriod: currentPeriod,
              nextPrayer: nextPrayer,
              now: _now,
            );
          } else {
            heroTiming = _selectedDateHeroTiming(selectedDay);
            highlightedPrayer = null;
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              EquranSpacing.pagePadding,
              14,
              EquranSpacing.pagePadding,
              28,
            ),
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      PrayerHeroCard(
                        day: selectedDay,
                        nextPrayer: NextPrayer(
                          entry: heroTiming.entry,
                          countdown: heroTiming.countdown,
                        ),
                        currentPrayer: heroCurrentPrayer,
                        titleOverride: heroTitleOverride,
                        subtitleOverride:
                            heroSubtitleOverride ??
                            (isViewingToday
                                ? null
                                : _formatDate(selectedDay.date)),
                        onTap: _openPrayerSettings,
                      ),
                      const SizedBox(height: 14),
                      _buildPrayerInfoCard(
                        context,
                        selectedDay,
                        isViewingToday,
                      ),
                      const SizedBox(height: 12),
                      _buildNightTimesCard(
                        context,
                        selectedDay,
                        nextSelectedDay,
                        settings,
                      ),
                      const SizedBox(height: 14),
                      _buildPrayerGrid(
                        context,
                        selectedDay,
                        highlightedPrayer,
                        settings,
                      ),
                      const SizedBox(height: 14),
                      _buildDisclaimer(context),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSetupState(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final TextStyle? buttonTextStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: colors.mint,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Icon(
                            Icons.add_location_alt_outlined,
                            color: colors.primary,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Prayer times need a location',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Calculate Fajr, Dhuhr, Asr, Maghrib and Isha for your exact location.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Your location is only used for prayer time calculation.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.textMuted,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLocating ? null : _useCurrentLocation,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                            textStyle: buttonTextStyle,
                          ),
                          icon: _isLocating
                              ? SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.my_location_rounded),
                          label: const Text('Use current location'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _chooseOnMap(null),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: colors.primary,
                            side: BorderSide(color: colors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                            textStyle: buttonTextStyle,
                          ),
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Choose on map'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => _chooseManually(null),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.textMuted,
                          backgroundColor: Colors.transparent,
                          textStyle: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textMuted,
                            letterSpacing: 0,
                          ),
                        ),
                        child: const Text('Enter coordinates manually'),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Times are calculated locally on your device.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textMuted,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrayerInfoCard(
    BuildContext context,
    PrayerDay day,
    bool isViewingToday,
  ) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final String dateLabel = isViewingToday ? 'Today' : _formatDate(day.date);
    final BorderRadius dateButtonRadius = BorderRadius.circular(
      AppRadii.medium,
    );

    return EquranSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      backgroundColor: colors.surface,
      borderColor: colors.border,
      child: Row(
        children: <Widget>[
          _PrayerDateArrowButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Previous day',
            onPressed: () => _movePrayerDate(day.date, -1),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              borderRadius: dateButtonRadius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: dateButtonRadius,
                onTap: () => _selectPrayerDate(day.date),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      dateLabel,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _PrayerDateArrowButton(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Next day',
            onPressed: () => _movePrayerDate(day.date, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildNightTimesCard(
    BuildContext context,
    PrayerDay day,
    PrayerDay nextDay,
    PrayerTimeSettings settings,
  ) {
    final EquranColors colors = context.equranColors;
    final _NightTimes nightTimes = _nightTimesFor(day, nextDay);

    return EquranSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      backgroundColor: colors.paleGreen,
      borderColor: colors.border,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _NightTimeValue(
              icon: Icons.nights_stay_outlined,
              label: 'Middle of night',
              value: _formatTime(nightTimes.middle, settings.use24HourFormat),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NightTimeValue(
              icon: Icons.dark_mode_outlined,
              label: 'Last third starts',
              value: _formatTime(
                nightTimes.lastThirdStart,
                settings.use24HourFormat,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerGrid(
    BuildContext context,
    PrayerDay day,
    PrayerTimeKind? highlightedKind,
    PrayerTimeSettings settings,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 700 ? 3 : 2;
        return GridView.builder(
          itemCount: day.entries.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: columns == 3 ? 146 : 142,
          ),
          itemBuilder: (BuildContext context, int index) {
            final PrayerTimeEntry entry = day.entries[index];
            return PrayerTimeThumbCard(
              entry: entry,
              isActive:
                  highlightedKind != null && entry.kind == highlightedKind,
              use24HourFormat: settings.use24HourFormat,
            );
          },
        );
      },
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withAlpha(110),
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: colors.border.withAlpha(140)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.info_outline_rounded, color: colors.textMuted, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Prayer times are calculated locally. Verify with your local mosque if needed.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });
    final PrayerLocationResult result = await _locationService
        .currentDeviceLocation();
    if (!mounted) return;
    setState(() {
      _isLocating = false;
    });

    final PrayerLocation? location = result.location;
    if (location != null) {
      await _store.saveLocation(location);
      await _rescheduleReminders(location);
      if (!mounted) return;
      _showMessage('Location saved.');
      return;
    }

    _showLocationError(result);
  }

  Future<void> _refreshCurrentDeviceLocationOnEntry() async {
    final PrayerLocation? savedLocation = _store.getLocation();
    if (savedLocation?.mode != PrayerLocationMode.currentDevice) return;

    setState(() {
      _isLocating = true;
    });
    final PrayerLocationResult result = await _locationService
        .currentDeviceLocation();
    if (!mounted) return;
    setState(() {
      _isLocating = false;
    });

    final PrayerLocation? location = result.location;
    if (location == null) {
      _showLocationError(result);
      return;
    }

    await _store.saveLocation(location);
    await _rescheduleReminders(location);
  }

  Future<void> _chooseManually(PrayerLocation? initialLocation) async {
    final PrayerLocation? location = await Navigator.of(context).push(
      MaterialPageRoute<PrayerLocation>(
        builder: (BuildContext context) =>
            ManualPrayerLocationPage(initialLocation: initialLocation),
      ),
    );
    if (location == null) return;
    await _saveResolvedLocation(location);
    if (!mounted) return;
    _showMessage('Location saved.');
  }

  Future<void> _chooseOnMap(PrayerLocation? initialLocation) async {
    final PrayerLocationPicker picker =
        widget.mapLocationPicker ?? showPrayerMapLocationPicker;
    final PrayerLocation? location = await picker(context, initialLocation);
    if (location == null) return;
    await _saveResolvedLocation(location);
    if (!mounted) return;
    _showMessage('Location saved.');
  }

  // ignore: unused_element
  Future<void> _showLocationDetails(PrayerLocation location) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext sheetContext) {
        return _LocationDetailsSheet(
          location: location,
          isLocating: _isLocating,
          onUpdateCurrentLocation: () {
            Navigator.of(sheetContext).pop();
            _useCurrentLocation();
          },
          onChooseMap: () {
            Navigator.of(sheetContext).pop();
            _chooseOnMap(location);
          },
          onSave: (_LocationDetailsSave detailsSave) async {
            await _saveResolvedLocation(
              detailsSave.location,
              previousLocation: location,
              preserveCustomLabel: detailsSave.preserveCustomLabel,
            );
            if (!mounted || !sheetContext.mounted) return;
            Navigator.of(sheetContext).pop();
            _showMessage('Location saved.');
          },
        );
      },
    );
  }

  Future<void> _saveResolvedLocation(
    PrayerLocation location, {
    PrayerLocation? previousLocation,
    bool preserveCustomLabel = false,
  }) async {
    final PrayerLocation resolvedLocation = await _locationService
        .resolveLocationForSave(
          location,
          previousLocation: previousLocation ?? _store.getLocation(),
          preserveCustomLabel: preserveCustomLabel,
        );
    await _store.saveLocation(resolvedLocation);
    await _rescheduleReminders(resolvedLocation);
  }

  Future<void> _rescheduleReminders(PrayerLocation location) async {
    final PrayerTimeSettings settings = _store.getSettings();
    final PrayerNotificationScheduleResult result = await _notificationService
        .reschedule(settings: settings, location: location);
    if (result.status == PrayerNotificationScheduleStatus.permissionDenied &&
        settings.reminderSettings.remindersEnabled) {
      await _store.saveSettings(
        settings.copyWith(
          reminderSettings: settings.reminderSettings.copyWith(
            remindersEnabled: false,
          ),
        ),
      );
      if (!mounted) return;
      _showMessage('Notification permission is off. Reminders were disabled.');
    } else if (result.status ==
            PrayerNotificationScheduleStatus.exactAlarmDenied &&
        settings.reminderSettings.remindersEnabled) {
      if (!mounted) return;
      _showMessage(
        'Exact alarm permission is disabled. Prayer reminders may be delayed.',
      );
    }
  }

  void _openPrayerSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PrayerTimesSettingsPage(),
      ),
    );
  }

  Future<void> _selectPrayerDate(DateTime currentDate) async {
    final DateTime initialDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select prayer date',
    );
    if (pickedDate == null || !mounted) return;
    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    });
  }

  void _movePrayerDate(DateTime currentDate, int dayDelta) {
    setState(() {
      _selectedDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day + dayDelta,
      );
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showLocationError(PrayerLocationResult result) {
    final String message = result.message ?? 'Unable to get location.';
    final PrayerLocationFailureReason? reason = result.failureReason;
    final SnackBarAction? action = switch (reason) {
      PrayerLocationFailureReason.servicesDisabled => SnackBarAction(
        label: 'Settings',
        onPressed: () {
          _locationService.openLocationSettings();
        },
      ),
      PrayerLocationFailureReason.permissionDeniedForever => SnackBarAction(
        label: 'App settings',
        onPressed: () {
          _locationService.openAppSettings();
        },
      ),
      _ => null,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), action: action));
  }

  void _scheduleNextRefresh() {
    _timer?.cancel();
    final DateTime now = DateTime.now();
    final Duration elapsedThisMinute = Duration(
      seconds: now.second,
      milliseconds: now.millisecond,
      microseconds: now.microsecond,
    );
    final Duration delay = elapsedThisMinute == Duration.zero
        ? const Duration(minutes: 1)
        : const Duration(minutes: 1) - elapsedThisMinute;

    _timer = Timer(delay, () {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
      _scheduleNextRefresh();
    });
  }
}

class _PrayerHeroTiming {
  const _PrayerHeroTiming({
    required this.entry,
    required this.countdown,
    required this.isNow,
  });

  final PrayerTimeEntry entry;
  final Duration countdown;
  final bool isNow;
}

_PrayerHeroTiming _heroTimingFor(NextPrayer nextPrayer) {
  return _PrayerHeroTiming(
    entry: nextPrayer.entry,
    countdown: nextPrayer.countdown,
    isNow: false,
  );
}

_PrayerHeroTiming _selectedDateHeroTiming(PrayerDay day) {
  return _PrayerHeroTiming(
    entry: day.entryFor(PrayerTimeKind.fajr),
    countdown: Duration.zero,
    isNow: false,
  );
}

String? _heroTitleOverrideFor(PrayerCurrentPeriod period) {
  return switch (period.type) {
    PrayerCurrentPeriodType.sunriseProhibited => 'Sunrise',
    PrayerCurrentPeriodType.dhuhrProhibited => 'Zawal',
    PrayerCurrentPeriodType.sunsetProhibited => 'Sunset',
    PrayerCurrentPeriodType.beforeDhuhr => 'Morning',
    PrayerCurrentPeriodType.normalPrayer => null,
  };
}

String? _heroSubtitleOverrideFor({
  required PrayerCurrentPeriod currentPeriod,
  required NextPrayer nextPrayer,
  required DateTime now,
}) {
  return switch (currentPeriod.type) {
    PrayerCurrentPeriodType.sunriseProhibited =>
      'Prohibited time ends in ${_formatHeroCountdown(currentPeriod.endsAt.difference(now))}',
    PrayerCurrentPeriodType.dhuhrProhibited ||
    PrayerCurrentPeriodType.sunsetProhibited =>
      'Prohibited time ends in ${_formatHeroCountdown(currentPeriod.endsAt.difference(now))}',
    PrayerCurrentPeriodType.beforeDhuhr =>
      '${nextPrayer.entry.kind.label} begins in ${_formatHeroCountdown(nextPrayer.countdown)}',
    PrayerCurrentPeriodType.normalPrayer => null,
  };
}

String _formatHeroCountdown(Duration duration) {
  final Duration normalized = duration.isNegative ? Duration.zero : duration;
  final int hours = normalized.inHours;
  final int minutes = normalized.inMinutes.remainder(60);
  if (hours <= 0) return '$minutes min';
  return '${hours}h ${minutes}m';
}

class _NightTimes {
  const _NightTimes({required this.middle, required this.lastThirdStart});

  final DateTime middle;
  final DateTime lastThirdStart;
}

_NightTimes _nightTimesFor(PrayerDay day, PrayerDay nextDay) {
  final DateTime maghrib = day.entryFor(PrayerTimeKind.maghrib).time;
  DateTime nextFajr = nextDay.entryFor(PrayerTimeKind.fajr).time;
  if (!nextFajr.isAfter(maghrib)) {
    nextFajr = nextFajr.add(const Duration(days: 1));
  }
  final Duration night = nextFajr.difference(maghrib);
  return _NightTimes(
    middle: maghrib.add(Duration(microseconds: night.inMicroseconds ~/ 2)),
    lastThirdStart: maghrib.add(
      Duration(microseconds: (night.inMicroseconds * 2) ~/ 3),
    ),
  );
}

bool _isSameCalendarDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _LocationDetailsSheet extends StatefulWidget {
  const _LocationDetailsSheet({
    required this.location,
    required this.isLocating,
    required this.onUpdateCurrentLocation,
    required this.onChooseMap,
    required this.onSave,
  });

  final PrayerLocation location;
  final bool isLocating;
  final VoidCallback onUpdateCurrentLocation;
  final VoidCallback onChooseMap;
  final Future<void> Function(_LocationDetailsSave location) onSave;

  @override
  State<_LocationDetailsSheet> createState() => _LocationDetailsSheetState();
}

class _LocationDetailsSheetState extends State<_LocationDetailsSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final String _initialLabel;
  late final String _initialLatitudeText;
  late final String _initialLongitudeText;
  bool _advancedExpanded = false;
  bool _hasFieldChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initialLabel = widget.location.displayLabel;
    _initialLatitudeText = widget.location.latitude.toStringAsFixed(6);
    _initialLongitudeText = widget.location.longitude.toStringAsFixed(6);
    _labelController = TextEditingController(text: _initialLabel);
    _latitudeController = TextEditingController(text: _initialLatitudeText);
    _longitudeController = TextEditingController(text: _initialLongitudeText);
    _labelController.addListener(_updateFieldChanges);
    _latitudeController.addListener(_updateFieldChanges);
    _longitudeController.addListener(_updateFieldChanges);
  }

  @override
  void dispose() {
    _labelController.removeListener(_updateFieldChanges);
    _latitudeController.removeListener(_updateFieldChanges);
    _longitudeController.removeListener(_updateFieldChanges);
    _labelController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(AppRadii.medium),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Location details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SavedLocationPanel(location: widget.location),
              const SizedBox(height: 14),
              _LocationActionRow(
                icon: Icons.my_location_rounded,
                title: 'Update current location',
                subtitle: 'Use this device location',
                onTap: widget.isLocating || _isSaving
                    ? null
                    : widget.onUpdateCurrentLocation,
              ),
              const SizedBox(height: 8),
              _LocationActionRow(
                icon: Icons.map_outlined,
                title: 'Choose on map',
                subtitle: 'Move the map pin to a place',
                onTap: _isSaving ? null : widget.onChooseMap,
              ),
              const SizedBox(height: 14),
              _buildAdvancedCoordinates(context),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _advancedExpanded
                    ? Padding(
                        key: const ValueKey<String>('save-location-changes'),
                        padding: const EdgeInsets.only(top: 14),
                        child: FilledButton.icon(
                          onPressed: _isSaving || !_hasFieldChanges
                              ? null
                              : _save,
                          icon: _isSaving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: const Text('Save changes'),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedCoordinates(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          initiallyExpanded: _advancedExpanded,
          maintainState: true,
          onExpansionChanged: (bool expanded) {
            setState(() {
              _advancedExpanded = expanded;
            });
          },
          leading: Icon(Icons.tune_rounded, color: colors.primary),
          title: Text(
            'Advanced coordinates',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: _advancedExpanded
              ? null
              : Text(
                  'Edit only if you need precise coordinates',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
          children: <Widget>[
            TextFormField(
              controller: _labelController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Location label',
                hintText: 'Home, work, or city name',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _latitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                helperText: 'Use a value between -90 and 90.',
                prefixIcon: Icon(Icons.explore_outlined),
              ),
              validator: _advancedExpanded
                  ? (String? value) => validatePrayerCoordinate(
                      value,
                      min: -90,
                      max: 90,
                      label: 'Latitude',
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _longitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                helperText: 'Use a value between -180 and 180.',
                prefixIcon: Icon(Icons.public_rounded),
              ),
              validator: _advancedExpanded
                  ? (String? value) => validatePrayerCoordinate(
                      value,
                      min: -180,
                      max: 180,
                      label: 'Longitude',
                    )
                  : null,
              onFieldSubmitted: (_) {
                if (_hasFieldChanges) _save();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_advancedExpanded && !_hasFieldChanges) return;
    if (_formKey.currentState?.validate() != true) return;
    setState(() {
      _isSaving = true;
    });

    final double latitude = double.parse(_latitudeController.text.trim());
    final double longitude = double.parse(_longitudeController.text.trim());
    final String label = _labelController.text.trim().isEmpty
        ? widget.location.mode.label
        : _labelController.text.trim();
    final bool coordinatesChanged =
        latitude != widget.location.latitude ||
        longitude != widget.location.longitude;
    final bool labelChanged = label != _initialLabel;

    await widget.onSave(
      _LocationDetailsSave(
        location: PrayerLocation(
          latitude: latitude,
          longitude: longitude,
          label: coordinatesChanged && !labelChanged ? 'Saved location' : label,
          mode: coordinatesChanged
              ? PrayerLocationMode.manual
              : widget.location.mode,
          countryCode: coordinatesChanged ? null : widget.location.countryCode,
          timezoneId: coordinatesChanged ? null : widget.location.timezoneId,
        ),
        preserveCustomLabel: labelChanged,
      ),
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
  }

  void _updateFieldChanges() {
    final bool hasChanges =
        _labelController.text.trim() != _initialLabel ||
        _latitudeController.text.trim() != _initialLatitudeText ||
        _longitudeController.text.trim() != _initialLongitudeText;
    if (hasChanges == _hasFieldChanges) return;
    setState(() {
      _hasFieldChanges = hasChanges;
    });
  }
}

class _LocationDetailsSave {
  const _LocationDetailsSave({
    required this.location,
    required this.preserveCustomLabel,
  });

  final PrayerLocation location;
  final bool preserveCustomLabel;
}

class _SavedLocationPanel extends StatelessWidget {
  const _SavedLocationPanel({required this.location});

  final PrayerLocation location;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.place_outlined, color: colors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    location.displayLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _locationPrivacyText(location),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _locationPrivacyText(PrayerLocation location) {
  final String? timezoneId = location.timezoneId;
  final String timezoneText = timezoneId == null || timezoneId.isEmpty
      ? ''
      : ' Timezone: $timezoneId.';
  return 'Used locally for prayer-time calculation. Coordinates are stored on this device.$timezoneText';
}

class _LocationActionRow extends StatelessWidget {
  const _LocationActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool enabled = onTap != null;
    final BorderRadius radius = BorderRadius.circular(AppRadii.medium);

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.outlineVariant),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer.withValues(
                    alpha: enabled ? 0.58 : 0.28,
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
                child: Icon(
                  icon,
                  color: enabled
                      ? colors.onSecondaryContainer
                      : colors.onSurfaceVariant,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: enabled ? null : colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _LocationSummaryRow extends StatelessWidget {
  const _LocationSummaryRow({
    required this.location,
    required this.onTap,
    // ignore: unused_element_parameter
    this.onHero = false,
  });

  final PrayerLocation location;
  final VoidCallback onTap;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final EquranColors equranColors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.medium);

    return Material(
      color: onHero
          ? equranColors.onPrimary.withAlpha(24)
          : colors.surface.withValues(alpha: 0.54),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('prayer_location_summary'),
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.location_on_outlined,
                color: onHero
                    ? equranColors.onPrimaryMuted
                    : colors.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      location.displayLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onHero ? equranColors.onPrimaryMuted : null,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.manage_search_rounded,
                color: onHero
                    ? equranColors.onPrimaryMuted
                    : colors.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerDateArrowButton extends StatelessWidget {
  const _PrayerDateArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final BorderRadius radius = BorderRadius.circular(AppRadii.medium);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.mint.withAlpha(150),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: SizedBox.square(
            dimension: 40,
            child: Icon(icon, color: colors.primary, size: 24),
          ),
        ),
      ),
    );
  }
}

class _NightTimeValue extends StatelessWidget {
  const _NightTimeValue({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;

    return Row(
      children: <Widget>[
        Icon(icon, color: colors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatTime(DateTime time, bool use24HourFormat) {
  final int hour = time.hour;
  final int minute = time.minute;
  if (use24HourFormat) {
    return '${_two(hour)}:${_two(minute)}';
  }

  final String period = hour >= 12 ? 'PM' : 'AM';
  final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:${_two(minute)} $period';
}

String formatPrayerCountdownLabel(Duration duration, {bool isNow = false}) {
  if (isNow || duration == Duration.zero || duration.isNegative) return 'Now';
  if (duration < const Duration(minutes: 5)) return 'Very soon';

  final int totalMinutes = (duration.inSeconds / 60).ceil();
  final int hours = totalMinutes ~/ 60;
  if (hours > 0) {
    final int minutes = totalMinutes.remainder(60);
    return minutes == 0 ? 'In ${hours}h' : 'In ${hours}h ${minutes}m';
  }
  return 'In ${totalMinutes}m';
}

String _formatDate(DateTime date) {
  const List<String> weekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  const List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _two(int value) => value.toString().padLeft(2, '0');
