import 'dart:async';

import 'package:equran/backend/settings_db.dart';
import 'package:equran/prayer/manual_prayer_location_page.dart';
import 'package:equran/prayer/prayer_map_location_page.dart';
import 'package:equran/prayer/prayer_location_service.dart';
import 'package:equran/prayer/prayer_models.dart';
import 'package:equran/prayer/prayer_notification_service.dart';
import 'package:equran/prayer/prayer_settings_store.dart';
import 'package:equran/prayer/prayer_times_settings_page.dart';
import 'package:equran/prayer/prayer_times_service.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';

const String _appAssetBase = 'assets/images/app_assets';

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
                        _buildSetupState(context),
                        const SizedBox(height: 14),
                        _buildDisclaimer(context),
                      ],
                    ),
                  ),
                ),
              ],
            );
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
          final PrayerTimeEntry featuredPrayer;
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
            final PrayerTimeEntry currentPrayer = _currentPrayerPeriod(
              today: today,
              yesterday: yesterday,
              now: _now,
            );
            highlightedPrayer = currentPrayer.kind;
            featuredPrayer = currentPrayer;
          } else {
            heroTiming = _selectedDateHeroTiming(selectedDay);
            highlightedPrayer = null;
            featuredPrayer = heroTiming.entry;
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
                      _buildHeroCard(
                        context,
                        selectedDay,
                        heroTiming,
                        featuredPrayer,
                        settings,
                        isViewingToday,
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

  Widget _buildHeroCard(
    BuildContext context,
    PrayerDay day,
    _PrayerHeroTiming heroTiming,
    PrayerTimeEntry featuredPrayer,
    PrayerTimeSettings settings,
    bool isViewingToday,
  ) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final String prayerTime = _formatTime(
      featuredPrayer.time,
      settings.use24HourFormat,
    );
    final String countdown = _formatCountdown(heroTiming.countdown);
    final String title = featuredPrayer.kind == PrayerTimeKind.sunrise
        ? 'Sunrise Time'
        : '${featuredPrayer.kind.label} Time';

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 360;
        final bool use12HourTime = !settings.use24HourFormat;
        final double artWidth = (constraints.maxWidth * (compact ? 0.62 : 0.66))
            .clamp(compact ? 188.0 : 238.0, compact ? 218.0 : 304.0)
            .toDouble();
        final double trailingSpace = (artWidth - 10)
            .clamp(compact ? 166.0 : 210.0, compact ? 202.0 : 286.0)
            .toDouble();
        final double timeSize =
            (constraints.maxWidth * (use12HourTime ? 0.105 : 0.13))
                .clamp(
                  compact
                      ? (use12HourTime ? 30.0 : 34.0)
                      : (use12HourTime ? 34.0 : 40.0),
                  use12HourTime ? 40.0 : 48.0,
                )
                .toDouble();
        final double titleSize = (constraints.maxWidth * 0.052)
            .clamp(18.0, 22.0)
            .toDouble();

        return EquranGradientCard(
          onTap: _openPrayerSettings,
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 20,
            compact ? 18 : 20,
            compact ? 12 : 16,
            compact ? 18 : 20,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                right: -12,
                top: -8,
                bottom: -4,
                width: artWidth,
                child: _buildPrayerHeroArt(featuredPrayer.kind),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: compact ? 162 : 188,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              prayerTime,
                              maxLines: 1,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colors.onPrimary,
                                fontSize: timeSize,
                                fontWeight: FontWeight.w900,
                                height: 0.98,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 6 : 8),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.onPrimary,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: compact ? 12 : 16,
                            ),
                            child: SizedBox(
                              width: compact ? 88 : 104,
                              child: Divider(
                                height: 1,
                                color: colors.onPrimary.withAlpha(58),
                              ),
                            ),
                          ),
                          Text(
                            isViewingToday
                                ? '${heroTiming.entry.kind.label} begins in $countdown'
                                : _formatDate(day.date),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.onPrimaryMuted,
                              fontSize: compact ? 13 : null,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: trailingSpace),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerHeroArt(PrayerTimeKind kind) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(EquranRadii.large),
      child: ShaderMask(
        shaderCallback: (Rect bounds) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Colors.transparent, Colors.white, Colors.white],
          stops: <double>[0, 0.28, 1],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(6, 2, 0, 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  _prayerBannerAsset(kind),
                  width: constraints.maxWidth - 6,
                  height: constraints.maxHeight - 4,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      '$_appAssetBase/prayer_time.png',
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSetupState(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.large),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.alphaBlend(
              colors.primary.withAlpha(isLight ? 28 : 48),
              colors.surfaceContainerLow,
            ),
            colors.surfaceContainerLow,
          ],
        ),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.shadow.withValues(alpha: isLight ? 0.1 : 0.24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                  child: Icon(
                    Icons.add_location_alt_outlined,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Prayer times need a location',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose where to calculate Fajr, Sunrise, Dhuhr, Asr, Maghrib, and Isha.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.verified_user_outlined,
                  color: colors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your location is used only for local prayer-time calculation.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: _isLocating ? null : _useCurrentLocation,
                  icon: _isLocating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded),
                  label: const Text('Use current location'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _chooseOnMap(null),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Choose on map'),
                ),
                TextButton.icon(
                  onPressed: () => _chooseManually(null),
                  icon: const Icon(Icons.edit_location_alt_outlined),
                  label: const Text('Enter coordinates manually'),
                ),
              ],
            ),
          ],
        ),
      ),
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
              borderRadius: BorderRadius.circular(AppRadii.medium),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadii.medium),
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
            return _PrayerTimeCard(
              entry: entry,
              isNext: highlightedKind != null && entry.kind == highlightedKind,
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

PrayerTimeEntry _currentPrayerPeriod({
  required PrayerDay today,
  required PrayerDay yesterday,
  required DateTime now,
}) {
  final PrayerTimeEntry fajr = today.entryFor(PrayerTimeKind.fajr);
  final PrayerTimeEntry sunrise = today.entryFor(PrayerTimeKind.sunrise);
  final PrayerTimeEntry dhuhr = today.entryFor(PrayerTimeKind.dhuhr);
  final PrayerTimeEntry asr = today.entryFor(PrayerTimeKind.asr);
  final PrayerTimeEntry maghrib = today.entryFor(PrayerTimeKind.maghrib);
  final PrayerTimeEntry isha = today.entryFor(PrayerTimeKind.isha);

  if (now.isBefore(fajr.time)) return yesterday.entryFor(PrayerTimeKind.isha);
  if (now.isBefore(sunrise.time)) return fajr;
  if (now.isBefore(dhuhr.time)) return sunrise;
  if (now.isBefore(asr.time)) return dhuhr;
  if (now.isBefore(maghrib.time)) return asr;
  if (now.isBefore(isha.time)) return maghrib;
  return isha;
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

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.medium),
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

    return Material(
      color: onHero
          ? equranColors.onPrimary.withAlpha(24)
          : colors.surface.withValues(alpha: 0.54),
      borderRadius: BorderRadius.circular(AppRadii.medium),
      child: InkWell(
        key: const Key('prayer_location_summary'),
        borderRadius: BorderRadius.circular(AppRadii.medium),
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

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.mint.withAlpha(150),
        borderRadius: BorderRadius.circular(AppRadii.medium),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.medium),
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

class _PrayerTimeCard extends StatelessWidget {
  const _PrayerTimeCard({
    required this.entry,
    required this.isNext,
    required this.use24HourFormat,
  });

  final PrayerTimeEntry entry;
  final bool isNext;
  final bool use24HourFormat;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final bool isLight = theme.brightness == Brightness.light;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.large),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isNext ? colors.surfaceAlt : colors.surface,
          gradient: isNext
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color.alphaBlend(
                      colors.primary.withAlpha(isLight ? 34 : 42),
                      colors.surfaceAlt,
                    ),
                    colors.surfaceAlt,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(
            color: isNext ? colors.primary.withAlpha(190) : colors.border,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isNext
                  ? colors.primaryStrong.withAlpha(isLight ? 38 : 58)
                  : colors.shadow.withAlpha(isLight ? 12 : 26),
              blurRadius: isNext ? 20 : 14,
              offset: Offset(0, isNext ? 9 : 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.large),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double imageWidth = (constraints.maxWidth * 0.74)
                  .clamp(96.0, 132.0)
                  .toDouble();
              final double imageHeight = (constraints.maxHeight * 0.52)
                  .clamp(66.0, 90.0)
                  .toDouble();
              final Color primaryText = isNext
                  ? colors.primarySoft
                  : colors.textPrimary;

              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entry.kind.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: primaryText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (isNext)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          _prayerThumbAsset(entry.kind),
                          fit: BoxFit.contain,
                          width: imageWidth,
                          height: imageHeight,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _iconFor(entry.kind),
                              color: colors.primary,
                              size: imageHeight * 0.78,
                            );
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatTime(entry.time, use24HourFormat),
                          maxLines: 1,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: primaryText,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _iconFor(PrayerTimeKind kind) {
    return switch (kind) {
      PrayerTimeKind.fajr => Icons.nights_stay_rounded,
      PrayerTimeKind.sunrise => Icons.wb_twilight_rounded,
      PrayerTimeKind.dhuhr => Icons.wb_sunny_outlined,
      PrayerTimeKind.asr => Icons.light_mode_outlined,
      PrayerTimeKind.maghrib => Icons.wb_twilight_outlined,
      PrayerTimeKind.isha => Icons.dark_mode_outlined,
    };
  }
}

String _prayerThumbAsset(PrayerTimeKind kind) {
  return switch (kind) {
    PrayerTimeKind.fajr => '$_appAssetBase/fajr.png',
    PrayerTimeKind.sunrise => '$_appAssetBase/fajr.png',
    PrayerTimeKind.dhuhr => '$_appAssetBase/dhuhr.png',
    PrayerTimeKind.asr => '$_appAssetBase/asr.png',
    PrayerTimeKind.maghrib => '$_appAssetBase/maghrib.png',
    PrayerTimeKind.isha => '$_appAssetBase/isha.png',
  };
}

String _prayerBannerAsset(PrayerTimeKind kind) {
  return switch (kind) {
    PrayerTimeKind.fajr => '$_appAssetBase/fajr_banner.png',
    PrayerTimeKind.sunrise => '$_appAssetBase/fajr_banner.png',
    PrayerTimeKind.dhuhr => '$_appAssetBase/dhuhr_banner.png',
    PrayerTimeKind.asr => '$_appAssetBase/asr_banner.png',
    PrayerTimeKind.maghrib => '$_appAssetBase/maghrib_banner.png',
    PrayerTimeKind.isha => '$_appAssetBase/isha_banner.png',
  };
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

String _formatCountdown(Duration duration) {
  final Duration normalized = duration.isNegative ? Duration.zero : duration;
  final int hours = normalized.inHours;
  final int minutes = normalized.inMinutes.remainder(60);
  if (hours <= 0) return '$minutes min';
  return '${hours}h ${minutes}m';
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
