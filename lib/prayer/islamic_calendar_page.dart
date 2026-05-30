import 'package:equran/backend/settings_db.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/prayer/hijri_calendar.dart';
import 'package:equran/prayer/prayer_notification_service.dart';
import 'package:flutter/material.dart';

class IslamicCalendarPage extends StatefulWidget {
  const IslamicCalendarPage({super.key});

  @override
  State<IslamicCalendarPage> createState() => _IslamicCalendarPageState();
}

class _IslamicCalendarPageState extends State<IslamicCalendarPage> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;
  int _sightingOffset = 0;
  bool _fastingRemindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _sightingOffset = SettingsDB().get('hijri_offset', defaultValue: 0);
    _fastingRemindersEnabled = SettingsDB().get(
      'fasting_reminders_enabled',
      defaultValue: false,
    );
    _selectedDate = DateTime.now();
  }

  Future<void> _updateSightingOffset(int newOffset) async {
    await SettingsDB().put('hijri_offset', newOffset);
    setState(() {
      _sightingOffset = newOffset;
    });
    if (_fastingRemindersEnabled) {
      await _scheduleFastingReminders();
    }
  }

  Future<void> _toggleFastingReminders(bool value) async {
    await SettingsDB().put('fasting_reminders_enabled', value);
    setState(() {
      _fastingRemindersEnabled = value;
    });

    if (value) {
      final status = await FlutterPrayerLocalNotificationPlatform.instance
          .checkPermission();
      if (status != PrayerNotificationPermissionStatus.granted) {
        await FlutterPrayerLocalNotificationPlatform.instance
            .requestPermission();
      }
      await _scheduleFastingReminders();
    } else {
      await _cancelFastingReminders();
    }
  }

  Future<void> _scheduleFastingReminders() async {
    await _cancelFastingReminders();
    final DateTime now = DateTime.now();
    final int offset = _sightingOffset;

    int scheduledCount = 0;

    for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
      final DateTime date = DateTime(now.year, now.month, now.day + dayOffset);
      final HijriCalendar hijri = HijriCalendar.fromDate(date, offset: offset);
      final String? fastingReason = _getFastingReason(hijri);

      if (fastingReason != null) {
        // Fasting alert goes out at 8:00 PM the night before
        final DateTime reminderTime = DateTime(
          date.year,
          date.month,
          date.day - 1,
          20,
          0,
        );

        if (reminderTime.isAfter(now)) {
          final int notificationId = 82000 + dayOffset;
          await FlutterPrayerLocalNotificationPlatform.instance.schedule(
            id: notificationId,
            title: 'Fasting Reminder',
            body:
                'Tomorrow is ${hijri.toString()} ($fastingReason). Prepare your intention and Suhoor.',
            scheduledAt: reminderTime,
            payload: 'fasting:reminder:${hijri.toString()}',
          );
          scheduledCount++;
        }
      }
    }

    if (mounted && scheduledCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Scheduled $scheduledCount fasting reminders successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cancelFastingReminders() async {
    for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
      await FlutterPrayerLocalNotificationPlatform.instance.cancel(
        82000 + dayOffset,
      );
    }
  }

  String? _getFastingReason(HijriCalendar hijri) {
    if (hijri.hMonth == 9) return 'Ramadan Fasting Day';
    if (hijri.hMonth == 12 && hijri.hDay == 9) return 'Day of Arafah';
    if (hijri.hMonth == 1 && hijri.hDay == 9) return 'Tasua Fast';
    if (hijri.hMonth == 1 && hijri.hDay == 10) return 'Day of Ashura';
    if (hijri.hDay == 13 || hijri.hDay == 14 || hijri.hDay == 15) {
      return 'Ayyam al-Bid (White Day)';
    }
    return null;
  }

  String? _getIslamicOccasion(HijriCalendar hijri) {
    if (hijri.hMonth == 9) {
      if (hijri.hDay == 1) return 'First Day of Ramadan';
      if (<int>[21, 23, 25, 27, 29].contains(hijri.hDay)) {
        return 'Laylat al-Qadr (Blessed Night)';
      }
      return 'Ramadan Fasting Day';
    }
    if (hijri.hMonth == 10 && hijri.hDay == 1) return 'Eid al-Fitr';
    if (hijri.hMonth == 12 && hijri.hDay == 9) return 'Day of Arafah (Fasting)';
    if (hijri.hMonth == 12 && hijri.hDay == 10) return 'Eid al-Adha';
    if (hijri.hMonth == 1 && hijri.hDay == 1) return 'Islamic New Year';
    if (hijri.hMonth == 1 && hijri.hDay == 9) return 'Tasua (Fasting)';
    if (hijri.hMonth == 1 && hijri.hDay == 10) return 'Day of Ashura (Fasting)';
    if (hijri.hMonth == 8 && hijri.hDay == 15)
      return 'Shab-e-Barat (Blessed Night)';
    if (hijri.hMonth == 7 && hijri.hDay == 27)
      return 'Isra\' and Mi\'raj (Blessed Night)';
    if (hijri.hDay == 13 || hijri.hDay == 14 || hijri.hDay == 15) {
      return 'Ayyam al-Bid (White Day - Fasting)';
    }
    return null;
  }

  Color? _getDayHighlightColor(HijriCalendar hijri, EquranColors colors) {
    if (hijri.hMonth == 10 && hijri.hDay == 1) return colors.primary; // Eid
    if (hijri.hMonth == 12 && hijri.hDay == 10) return colors.primary; // Eid
    if (hijri.hMonth == 9) return colors.primary.withAlpha(20); // Ramadan
    if (hijri.hMonth == 12 && hijri.hDay == 9)
      return colors.mint.withAlpha(50); // Arafah
    if (hijri.hMonth == 1 && (hijri.hDay == 9 || hijri.hDay == 10)) {
      return colors.mint.withAlpha(50); // Ashura/Tasua
    }
    if (hijri.hDay == 13 || hijri.hDay == 14 || hijri.hDay == 15) {
      return colors.mint.withAlpha(25); // Ayyam al-Bid
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final EquranColors colors = context.equranColors;
    final ThemeData theme = Theme.of(context);

    // Days in current focused month
    final DateTime firstOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month,
      1,
    );
    final int blankDaysCount = firstOfMonth.weekday - 1; // Mon = 1
    final DateTime lastOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    );
    final int daysInMonthCount = lastOfMonth.day;

    final List<String> weekdays = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          // Settings & Setup Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Text('Offset: '),
                  DropdownButton<int>(
                    value: _sightingOffset,
                    onChanged: (int? val) {
                      if (val != null) _updateSightingOffset(val);
                    },
                    items: const <DropdownMenuItem<int>>[
                      DropdownMenuItem<int>(value: -1, child: Text('-1 day')),
                      DropdownMenuItem<int>(value: 0, child: Text('0 days')),
                      DropdownMenuItem<int>(value: 1, child: Text('+1 day')),
                    ],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  const Text('Fasting Alerts '),
                  Switch(
                    value: _fastingRemindersEnabled,
                    activeColor: colors.primary,
                    onChanged: _toggleFastingReminders,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Calendar Navigation Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(
                      _focusedDate.year,
                      _focusedDate.month - 1,
                    );
                  });
                },
              ),
              Text(
                '${_focusedDate.year} - ${_focusedDate.month.toString().padLeft(2, '0')}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(
                      _focusedDate.year,
                      _focusedDate.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekdays Grid Header
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.5,
            ),
            itemCount: 7,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: Text(
                  weekdays[index],
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textSecondary,
                  ),
                ),
              );
            },
          ),

          // Month Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: blankDaysCount + daysInMonthCount,
            itemBuilder: (BuildContext context, int index) {
              if (index < blankDaysCount) {
                return const SizedBox();
              }

              final int dayNumber = index - blankDaysCount + 1;
              final DateTime date = DateTime(
                _focusedDate.year,
                _focusedDate.month,
                dayNumber,
              );
              final HijriCalendar hijri = HijriCalendar.fromDate(
                date,
                offset: _sightingOffset,
              );

              final bool isSelected =
                  _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              final Color? highlightColor = _getDayHighlightColor(
                hijri,
                colors,
              );

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Card(
                  margin: const EdgeInsets.all(2),
                  color: isSelected
                      ? colors.primary.withAlpha(40)
                      : (highlightColor ??
                            theme.colorScheme.surfaceContainerLow),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.small),
                    side: BorderSide(
                      color: isSelected
                          ? colors.primary
                          : (highlightColor != null
                                ? colors.primary.withAlpha(120)
                                : colors.border),
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Text(
                          hijri.hDay.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: highlightColor != null
                                ? colors.primary
                                : colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Date Details Box
          if (_selectedDate != null) ...<Widget>[
            _buildDateDetailsCard(theme, colors),
          ],
        ],
      ),
    );
  }

  Widget _buildDateDetailsCard(ThemeData theme, EquranColors colors) {
    final DateTime selDate = _selectedDate!;
    final HijriCalendar hijri = HijriCalendar.fromDate(
      selDate,
      offset: _sightingOffset,
    );
    final String? occasion = _getIslamicOccasion(hijri);

    return Card(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.medium),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Selected Date',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${selDate.day}/${selDate.month}/${selDate.year} (Gregorian)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${hijri.toString()} (Hijri)',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (occasion != null) ...<Widget>[
              const Divider(height: 20),
              Row(
                children: <Widget>[
                  Icon(Icons.star_rounded, color: colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      occasion,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
