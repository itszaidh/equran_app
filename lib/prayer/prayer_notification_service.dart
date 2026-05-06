import 'dart:async';

import 'package:equran/prayer/prayer_models.dart';
import 'package:equran/prayer/prayer_times_service.dart';
import 'package:equran/prayer/prayer_timezone_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as timezone;

enum PrayerNotificationPermissionStatus { granted, denied, unsupported }

enum PrayerExactAlarmPermissionStatus { granted, denied, unsupported }

enum PrayerNotificationScheduleStatus {
  disabled,
  missingLocation,
  permissionDenied,
  exactAlarmDenied,
  unsupported,
  scheduled,
  failed,
}

class PrayerScheduledNotification {
  const PrayerScheduledNotification({
    required this.id,
    required this.prayer,
    required this.scheduledAt,
    required this.dayOffset,
  });

  final int id;
  final PrayerTimeKind prayer;
  final DateTime scheduledAt;
  final int dayOffset;
}

class PrayerNotificationScheduleResult {
  const PrayerNotificationScheduleResult({
    required this.status,
    this.scheduledNotifications = const <PrayerScheduledNotification>[],
    this.notificationPermission,
    this.exactAlarmPermission,
    this.message,
  });

  final PrayerNotificationScheduleStatus status;
  final List<PrayerScheduledNotification> scheduledNotifications;
  final PrayerNotificationPermissionStatus? notificationPermission;
  final PrayerExactAlarmPermissionStatus? exactAlarmPermission;
  final String? message;

  int get scheduledCount => scheduledNotifications.length;
}

abstract class PrayerLocalNotificationPlatform {
  Future<void> initialize();

  Future<PrayerNotificationPermissionStatus> checkPermission();

  Future<PrayerNotificationPermissionStatus> requestPermission();

  Future<void> openSettings();

  Future<PrayerExactAlarmPermissionStatus> checkExactAlarmPermission();

  Future<void> openExactAlarmSettings();

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required String payload,
  });

  Future<void> cancel(int id);
}

class FlutterPrayerLocalNotificationPlatform
    implements PrayerLocalNotificationPlatform {
  FlutterPrayerLocalNotificationPlatform._();

  static final FlutterPrayerLocalNotificationPlatform instance =
      FlutterPrayerLocalNotificationPlatform._();

  static const Duration _operationTimeout = Duration(seconds: 8);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final _AndroidPrayerNotificationPermissionBridge _androidPermissions =
      const _AndroidPrayerNotificationPermissionBridge();

  bool _initialized = false;
  bool _timezoneConfigured = false;

  @override
  Future<void> initialize() async {
    if (_initialized || !_isSupported) return;
    await _plugin
        .initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('ic_prayer_notification'),
            iOS: DarwinInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false,
            ),
            macOS: DarwinInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false,
            ),
          ),
        )
        .timeout(_operationTimeout);
    _initialized = true;
  }

  @override
  Future<PrayerNotificationPermissionStatus> checkPermission() async {
    if (!_isSupported) return PrayerNotificationPermissionStatus.unsupported;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final PrayerNotificationPermissionStatus? nativeStatus =
          await _androidPermissions.checkPermission().timeout(
            _operationTimeout,
            onTimeout: () => null,
          );
      if (nativeStatus != null) return nativeStatus;

      await initialize();
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) {
        return PrayerNotificationPermissionStatus.unsupported;
      }
      final bool? enabled = await android.areNotificationsEnabled().timeout(
        _operationTimeout,
      );
      return enabled == true
          ? PrayerNotificationPermissionStatus.granted
          : PrayerNotificationPermissionStatus.denied;
    }

    await initialize();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios == null) return PrayerNotificationPermissionStatus.unsupported;
      final NotificationsEnabledOptions? permissions = await ios
          .checkPermissions()
          .timeout(_operationTimeout);
      return permissions?.isEnabled == true
          ? PrayerNotificationPermissionStatus.granted
          : PrayerNotificationPermissionStatus.denied;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final MacOSFlutterLocalNotificationsPlugin? macOS = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      if (macOS == null) return PrayerNotificationPermissionStatus.unsupported;
      final NotificationsEnabledOptions? permissions = await macOS
          .checkPermissions()
          .timeout(_operationTimeout);
      return permissions?.isEnabled == true
          ? PrayerNotificationPermissionStatus.granted
          : PrayerNotificationPermissionStatus.denied;
    }

    return PrayerNotificationPermissionStatus.unsupported;
  }

  @override
  Future<PrayerNotificationPermissionStatus> requestPermission() async {
    if (!_isSupported) return PrayerNotificationPermissionStatus.unsupported;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final PrayerNotificationPermissionStatus? nativeStatus =
          await _androidPermissions.requestPermission().timeout(
            _operationTimeout,
            onTimeout: () => null,
          );
      if (nativeStatus != null) return nativeStatus;

      await initialize();
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) {
        return PrayerNotificationPermissionStatus.unsupported;
      }
      final bool? granted = await android
          .requestNotificationsPermission()
          .timeout(_operationTimeout);
      return granted == true
          ? PrayerNotificationPermissionStatus.granted
          : PrayerNotificationPermissionStatus.denied;
    }

    await initialize();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios == null) return PrayerNotificationPermissionStatus.unsupported;
      final bool? granted = await ios
          .requestPermissions(alert: true, sound: true)
          .timeout(_operationTimeout);
      return granted == true
          ? PrayerNotificationPermissionStatus.granted
          : PrayerNotificationPermissionStatus.denied;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final MacOSFlutterLocalNotificationsPlugin? macOS = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      if (macOS == null) return PrayerNotificationPermissionStatus.unsupported;
      final bool? granted = await macOS
          .requestPermissions(alert: true, sound: true)
          .timeout(_operationTimeout);
      return granted == true
          ? PrayerNotificationPermissionStatus.granted
          : PrayerNotificationPermissionStatus.denied;
    }

    return PrayerNotificationPermissionStatus.unsupported;
  }

  @override
  Future<void> openSettings() async {
    if (!_isSupported) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final bool opened = await _androidPermissions.openSettings().timeout(
        _operationTimeout,
        onTimeout: () => false,
      );
      if (opened) return;
    }
  }

  @override
  Future<PrayerExactAlarmPermissionStatus> checkExactAlarmPermission() async {
    if (!_isSupported) return PrayerExactAlarmPermissionStatus.unsupported;
    if (defaultTargetPlatform != TargetPlatform.android) {
      return PrayerExactAlarmPermissionStatus.unsupported;
    }

    final PrayerExactAlarmPermissionStatus? nativeStatus =
        await _androidPermissions.checkExactAlarmPermission().timeout(
          _operationTimeout,
          onTimeout: () => null,
        );
    if (nativeStatus != null) return nativeStatus;

    await initialize();
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return PrayerExactAlarmPermissionStatus.unsupported;
    final bool? granted = await android.canScheduleExactNotifications().timeout(
      _operationTimeout,
    );
    return granted == true
        ? PrayerExactAlarmPermissionStatus.granted
        : PrayerExactAlarmPermissionStatus.denied;
  }

  @override
  Future<void> openExactAlarmSettings() async {
    if (!_isSupported || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    final bool opened = await _androidPermissions
        .openExactAlarmSettings()
        .timeout(_operationTimeout, onTimeout: () => false);
    if (opened) return;

    await initialize();
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestExactAlarmsPermission().timeout(_operationTimeout);
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required String payload,
  }) async {
    if (!_isSupported) return;
    await initialize();
    await _configureTimezone();
    final timezone.TZDateTime scheduledDate = _scheduledDateFor(scheduledAt);
    await _plugin
        .zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_reminders',
              'Prayer reminders',
              channelDescription: 'Local reminders for enabled prayer times.',
              icon: 'ic_prayer_notification',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            ),
            macOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        )
        .timeout(_operationTimeout);
  }

  @override
  Future<void> cancel(int id) async {
    if (!_isSupported) return;
    await initialize();
    await _plugin.cancel(id: id).timeout(_operationTimeout);
  }

  bool get _isSupported {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  Future<void> _configureTimezone() async {
    if (_timezoneConfigured) return;
    await PrayerTimezoneService.configureDeviceTimezone().timeout(
      _operationTimeout,
    );
    _timezoneConfigured = true;
  }

  timezone.TZDateTime _scheduledDateFor(DateTime scheduledAt) {
    final timezone.TZDateTime localScheduledAt = timezone.TZDateTime.from(
      scheduledAt,
      timezone.local,
    );
    return timezone.TZDateTime(
      timezone.local,
      localScheduledAt.year,
      localScheduledAt.month,
      localScheduledAt.day,
      localScheduledAt.hour,
      localScheduledAt.minute,
      localScheduledAt.second,
    );
  }
}

class _AndroidPrayerNotificationPermissionBridge {
  const _AndroidPrayerNotificationPermissionBridge();

  static const MethodChannel _channel = MethodChannel(
    'com.app.equran/notification_permissions',
  );

  Future<PrayerNotificationPermissionStatus?> checkPermission() {
    return _invokePermissionStatus('checkNotificationPermission');
  }

  Future<PrayerNotificationPermissionStatus?> requestPermission() {
    return _invokePermissionStatus('requestNotificationPermission');
  }

  Future<PrayerExactAlarmPermissionStatus?> checkExactAlarmPermission() {
    return _invokeExactAlarmStatus('checkExactAlarmPermission');
  }

  Future<bool> openSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openNotificationSettings') ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openExactAlarmSettings() async {
    try {
      return await _channel.invokeMethod<bool>('openExactAlarmSettings') ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<PrayerNotificationPermissionStatus?> _invokePermissionStatus(
    String method,
  ) async {
    try {
      final String? status = await _channel.invokeMethod<String>(method);
      return switch (status) {
        'granted' => PrayerNotificationPermissionStatus.granted,
        'denied' => PrayerNotificationPermissionStatus.denied,
        'unsupported' => PrayerNotificationPermissionStatus.unsupported,
        _ => null,
      };
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<PrayerExactAlarmPermissionStatus?> _invokeExactAlarmStatus(
    String method,
  ) async {
    try {
      final String? status = await _channel.invokeMethod<String>(method);
      return switch (status) {
        'granted' => PrayerExactAlarmPermissionStatus.granted,
        'denied' => PrayerExactAlarmPermissionStatus.denied,
        'unsupported' => PrayerExactAlarmPermissionStatus.unsupported,
        _ => null,
      };
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}

class PrayerNotificationService {
  PrayerNotificationService({
    PrayerLocalNotificationPlatform? platform,
    PrayerTimesService prayerTimesService = const PrayerTimesService(),
    DateTime Function()? nowProvider,
    this.scheduleDays = defaultScheduleDays,
  }) : _platform = platform ?? FlutterPrayerLocalNotificationPlatform.instance,
       _prayerTimesService = prayerTimesService,
       _nowProvider = nowProvider ?? DateTime.now;

  static const int defaultScheduleDays = 7;
  static const int _notificationBaseId = 42000;
  static const int _datedNotificationBaseId = 52000;
  static const int _debugNotificationId = 41999;
  static const String _androidPrayerScheduleMode =
      'AndroidScheduleMode.exactAllowWhileIdle';
  static const Duration _operationTimeout = Duration(seconds: 8);
  static final DateTime _notificationIdEpoch = DateTime.utc(2020);

  final PrayerLocalNotificationPlatform _platform;
  final PrayerTimesService _prayerTimesService;
  final DateTime Function() _nowProvider;
  final int scheduleDays;

  Future<void> initialize() {
    return _withTimeout(_platform.initialize());
  }

  Future<PrayerNotificationPermissionStatus> checkPermission() {
    return _withTimeout(_platform.checkPermission());
  }

  Future<PrayerNotificationPermissionStatus> requestPermission() {
    return _withTimeout(_platform.requestPermission());
  }

  Future<PrayerExactAlarmPermissionStatus> checkExactAlarmPermission() {
    return _withTimeout(_platform.checkExactAlarmPermission());
  }

  Future<void> openSettings() {
    return _withTimeout(_platform.openSettings());
  }

  Future<void> openExactAlarmSettings() {
    return _withTimeout(_platform.openExactAlarmSettings());
  }

  Future<void> cancelPrayerNotifications({DateTime? anchorDate}) async {
    final DateTime anchor = _dateOnly(anchorDate ?? _nowProvider().toLocal());
    await _withTimeout(_platform.cancel(_debugNotificationId));

    for (int dayOffset = -2; dayOffset < scheduleDays + 3; dayOffset++) {
      final DateTime date = DateTime(
        anchor.year,
        anchor.month,
        anchor.day + dayOffset,
      );
      for (final PrayerTimeKind prayer in PrayerTimeKind.reminderOrder) {
        await _withTimeout(
          _platform.cancel(notificationIdForDate(prayer, date)),
        );
      }
    }

    for (int dayOffset = 0; dayOffset < scheduleDays; dayOffset++) {
      for (final PrayerTimeKind prayer in PrayerTimeKind.reminderOrder) {
        await _withTimeout(
          _platform.cancel(notificationIdFor(prayer, dayOffset)),
        );
      }
    }
  }

  Future<PrayerNotificationScheduleResult>
  scheduleDebugExactNotificationOneMinuteFromNow() async {
    if (!kDebugMode) {
      return const PrayerNotificationScheduleResult(
        status: PrayerNotificationScheduleStatus.unsupported,
        message: 'Debug prayer notification scheduling is unavailable.',
      );
    }

    try {
      await _prepareForScheduling();
      final PrayerNotificationPermissionStatus permission = await _withTimeout(
        _platform.checkPermission(),
      );
      if (permission != PrayerNotificationPermissionStatus.granted) {
        return PrayerNotificationScheduleResult(
          status: PrayerNotificationScheduleStatus.permissionDenied,
          notificationPermission: permission,
          message: 'Notification permission is off.',
        );
      }

      final PrayerExactAlarmPermissionStatus exactAlarmPermission =
          await _withTimeout(_platform.checkExactAlarmPermission());
      if (exactAlarmPermission == PrayerExactAlarmPermissionStatus.denied) {
        return PrayerNotificationScheduleResult(
          status: PrayerNotificationScheduleStatus.exactAlarmDenied,
          notificationPermission: permission,
          exactAlarmPermission: exactAlarmPermission,
          message:
              'Exact alarm permission is disabled. Prayer reminders may be delayed.',
        );
      }

      await _withTimeout(_platform.cancel(_debugNotificationId));
      final DateTime now = _nowProvider();
      final DateTime scheduledAt = _zeroSubsecond(
        now.add(const Duration(minutes: 1)),
      );
      await _scheduleNotification(
        id: _debugNotificationId,
        prayer: PrayerTimeKind.fajr,
        title: 'Prayer reminder test ${_debugTimeLabel(scheduledAt)}',
        body:
            'Expected exact delivery at ${_debugTimeLabel(scheduledAt)} using $_androidPrayerScheduleMode.',
        prayerTime: scheduledAt,
        reminderOffsetMinutes: 0,
        scheduledAt: scheduledAt,
        now: now,
        timezoneName: PrayerTimezoneService.deviceTimezoneId ?? 'local',
        notificationPermission: permission,
        exactAlarmPermission: exactAlarmPermission,
        payload: 'prayer:debug:${scheduledAt.toIso8601String()}',
      );

      return PrayerNotificationScheduleResult(
        status: PrayerNotificationScheduleStatus.scheduled,
        notificationPermission: permission,
        exactAlarmPermission: exactAlarmPermission,
        scheduledNotifications: <PrayerScheduledNotification>[
          PrayerScheduledNotification(
            id: _debugNotificationId,
            prayer: PrayerTimeKind.fajr,
            scheduledAt: scheduledAt,
            dayOffset: 0,
          ),
        ],
      );
    } on TimeoutException {
      return const PrayerNotificationScheduleResult(
        status: PrayerNotificationScheduleStatus.failed,
        message:
            'Notification setup timed out. Check notification permission and try again.',
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Prayer debug notification scheduling failed: $error');
      }
      return PrayerNotificationScheduleResult(
        status: PrayerNotificationScheduleStatus.failed,
        message: error.toString(),
      );
    }
  }

  Future<PrayerNotificationScheduleResult> reschedule({
    required PrayerTimeSettings settings,
    required PrayerLocation? location,
    bool requestPermission = false,
  }) async {
    try {
      final PrayerReminderSettings reminders = settings.reminderSettings;
      final DateTime now = _nowProvider();
      final DateTime? today = location == null
          ? null
          : _prayerTimesService.calendarDateForInstant(
              instant: now,
              location: location,
              settings: settings,
            );

      await _prepareForScheduling();
      await cancelPrayerNotifications(anchorDate: today);

      if (!reminders.remindersEnabled || reminders.enabledPrayerKinds.isEmpty) {
        return const PrayerNotificationScheduleResult(
          status: PrayerNotificationScheduleStatus.disabled,
        );
      }

      if (location == null) {
        return const PrayerNotificationScheduleResult(
          status: PrayerNotificationScheduleStatus.missingLocation,
          message: 'Choose a location before scheduling reminders.',
        );
      }
      final DateTime todayDate = today!;

      final PrayerNotificationPermissionStatus permission = requestPermission
          ? await _withTimeout(_platform.requestPermission())
          : await _withTimeout(_platform.checkPermission());
      if (permission == PrayerNotificationPermissionStatus.unsupported) {
        return const PrayerNotificationScheduleResult(
          status: PrayerNotificationScheduleStatus.unsupported,
          notificationPermission:
              PrayerNotificationPermissionStatus.unsupported,
          message: 'Prayer reminders are not supported on this platform.',
        );
      }
      if (permission != PrayerNotificationPermissionStatus.granted) {
        return PrayerNotificationScheduleResult(
          status: PrayerNotificationScheduleStatus.permissionDenied,
          notificationPermission: permission,
          message: 'Notification permission is off.',
        );
      }

      final PrayerExactAlarmPermissionStatus exactAlarmPermission =
          await _withTimeout(_platform.checkExactAlarmPermission());
      if (exactAlarmPermission == PrayerExactAlarmPermissionStatus.denied) {
        if (kDebugMode) {
          debugPrint(
            'Prayer notifications not scheduled: exact alarm permission is disabled.',
          );
        }
        return PrayerNotificationScheduleResult(
          status: PrayerNotificationScheduleStatus.exactAlarmDenied,
          notificationPermission: permission,
          exactAlarmPermission: exactAlarmPermission,
          message:
              'Exact alarm permission is disabled. Prayer reminders may be delayed.',
        );
      }

      final List<PrayerScheduledNotification> scheduled =
          <PrayerScheduledNotification>[];

      for (int dayOffset = 0; dayOffset < scheduleDays; dayOffset++) {
        final DateTime date = DateTime(
          todayDate.year,
          todayDate.month,
          todayDate.day + dayOffset,
        );
        final PrayerDay day = _prayerTimesService.calculateDay(
          date: date,
          location: location,
          settings: settings,
        );

        for (final PrayerTimeKind prayer in PrayerTimeKind.reminderOrder) {
          if (!reminders.isReminderActiveFor(prayer)) continue;
          final DateTime prayerTime = _floorToMinute(day.entryFor(prayer).time);
          final DateTime scheduledAt = _floorToMinute(
            prayerTime.subtract(
              Duration(minutes: reminders.reminderOffsetMinutes),
            ),
          );
          if (!scheduledAt.isAfter(now)) continue;

          final int id = notificationIdForDate(prayer, date);
          await _scheduleNotification(
            id: id,
            prayer: prayer,
            title: prayer.label,
            body: _notificationBody(prayer, reminders.reminderOffsetMinutes),
            prayerTime: prayerTime,
            reminderOffsetMinutes: reminders.reminderOffsetMinutes,
            scheduledAt: scheduledAt,
            now: now,
            timezoneName:
                day.timezoneId ??
                PrayerTimezoneService.deviceTimezoneId ??
                'local',
            notificationPermission: permission,
            exactAlarmPermission: exactAlarmPermission,
            payload: 'prayer:${prayer.id}:${scheduledAt.toIso8601String()}',
          );
          scheduled.add(
            PrayerScheduledNotification(
              id: id,
              prayer: prayer,
              scheduledAt: scheduledAt,
              dayOffset: dayOffset,
            ),
          );
        }
      }

      if (kDebugMode) {
        debugPrint(
          'Prayer notifications scheduled: ${scheduled.length} '
          'over $scheduleDays days',
        );
      }

      return PrayerNotificationScheduleResult(
        status: PrayerNotificationScheduleStatus.scheduled,
        scheduledNotifications: scheduled,
        notificationPermission: permission,
        exactAlarmPermission: exactAlarmPermission,
      );
    } on TimeoutException {
      return const PrayerNotificationScheduleResult(
        status: PrayerNotificationScheduleStatus.failed,
        message:
            'Notification setup timed out. Check notification permission and try again.',
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Prayer notification scheduling failed: $error');
      }
      return PrayerNotificationScheduleResult(
        status: PrayerNotificationScheduleStatus.failed,
        message: error.toString(),
      );
    }
  }

  int notificationIdForDate(PrayerTimeKind prayer, DateTime date) {
    final int prayerIndex = PrayerTimeKind.reminderOrder.indexOf(prayer);
    if (prayerIndex < 0) {
      throw ArgumentError('Unsupported prayer notification id: $prayer');
    }
    final DateTime normalizedDate = DateTime.utc(
      date.year,
      date.month,
      date.day,
    );
    final int dayIndex = normalizedDate.difference(_notificationIdEpoch).inDays;
    if (dayIndex < 0) {
      throw ArgumentError('Unsupported prayer notification date: $date');
    }
    return _datedNotificationBaseId + (dayIndex * 10) + prayerIndex;
  }

  int notificationIdFor(PrayerTimeKind prayer, int dayOffset) {
    final int prayerIndex = PrayerTimeKind.reminderOrder.indexOf(prayer);
    if (prayerIndex < 0 || dayOffset < 0) {
      throw ArgumentError('Unsupported prayer notification id: $prayer');
    }
    return _notificationBaseId + (dayOffset * 10) + prayerIndex;
  }

  String _notificationBody(PrayerTimeKind prayer, int offsetMinutes) {
    if (offsetMinutes <= 0) {
      return 'It is time for ${prayer.label} prayer.';
    }
    return '${prayer.label} prayer is in $offsetMinutes minutes.';
  }

  Future<void> _prepareForScheduling() async {
    await _withTimeout(_platform.initialize());
    PrayerTimezoneService.ensureDatabaseInitialized();
  }

  Future<void> _scheduleNotification({
    required int id,
    required PrayerTimeKind prayer,
    required String title,
    required String body,
    required DateTime prayerTime,
    required int reminderOffsetMinutes,
    required DateTime scheduledAt,
    required DateTime now,
    required String timezoneName,
    required PrayerNotificationPermissionStatus notificationPermission,
    required PrayerExactAlarmPermissionStatus exactAlarmPermission,
    required String payload,
  }) async {
    _logSchedule(
      id: id,
      prayer: prayer,
      prayerTime: prayerTime,
      reminderOffsetMinutes: reminderOffsetMinutes,
      scheduledAt: scheduledAt,
      now: now,
      timezoneName: timezoneName,
      notificationPermission: notificationPermission,
      exactAlarmPermission: exactAlarmPermission,
    );
    await _withTimeout(
      _platform.schedule(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        payload: payload,
      ),
    );
  }

  void _logSchedule({
    required int id,
    required PrayerTimeKind prayer,
    required DateTime prayerTime,
    required int reminderOffsetMinutes,
    required DateTime scheduledAt,
    required DateTime now,
    required String timezoneName,
    required PrayerNotificationPermissionStatus notificationPermission,
    required PrayerExactAlarmPermissionStatus exactAlarmPermission,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'Prayer notification schedule | '
      'prayer=${prayer.label} | '
      'uiPrayerClock=${_debugWallClockLabel(prayerTime)} | '
      'uiPrayerTime=${prayerTime.toIso8601String()} | '
      'reminderOffsetMinutes=$reminderOffsetMinutes | '
      'scheduledNotificationClock=${_debugWallClockLabel(scheduledAt)} | '
      'scheduledNotificationTime=${scheduledAt.toIso8601String()} | '
      'deviceNowClock=${_debugTimeLabel(now)} | '
      'deviceNow=${now.toLocal().toIso8601String()} | '
      'prayerTimezone=$timezoneName | '
      'deviceScheduleTimezone=${PrayerTimezoneService.deviceTimezoneId ?? timezone.local.name} | '
      'notificationId=$id | '
      'androidScheduleMode=$_androidPrayerScheduleMode | '
      'exactAlarmPermission=$exactAlarmPermission | '
      'exactAlarmPermissionGranted=${exactAlarmPermission == PrayerExactAlarmPermissionStatus.granted} | '
      'notificationPermission=$notificationPermission | '
      'notificationPermissionGranted=${notificationPermission == PrayerNotificationPermissionStatus.granted}',
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _floorToMinute(DateTime time) {
    if (time is timezone.TZDateTime) {
      return timezone.TZDateTime(
        time.location,
        time.year,
        time.month,
        time.day,
        time.hour,
        time.minute,
      );
    }
    if (time.isUtc) {
      return DateTime.utc(
        time.year,
        time.month,
        time.day,
        time.hour,
        time.minute,
      );
    }
    return DateTime(time.year, time.month, time.day, time.hour, time.minute);
  }

  DateTime _zeroSubsecond(DateTime time) {
    if (time is timezone.TZDateTime) {
      return timezone.TZDateTime(
        time.location,
        time.year,
        time.month,
        time.day,
        time.hour,
        time.minute,
        time.second,
      );
    }
    if (time.isUtc) {
      return DateTime.utc(
        time.year,
        time.month,
        time.day,
        time.hour,
        time.minute,
        time.second,
      );
    }
    return DateTime(
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
    );
  }

  String _debugTimeLabel(DateTime time) {
    final DateTime local = time.toLocal();
    return _clockWithSeconds(local);
  }

  String _debugWallClockLabel(DateTime time) {
    return _clockWithSeconds(time);
  }

  String _clockWithSeconds(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }

  Future<T> _withTimeout<T>(Future<T> future) {
    return future.timeout(_operationTimeout);
  }
}
