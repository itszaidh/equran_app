import 'package:equran/prayer/prayer_models.dart';
import 'package:equran/prayer/prayer_notification_service.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/theme/equran_spacing.dart';
import 'package:equran/widgets/common/equran_components.dart';
import 'package:flutter/material.dart';

const String _appAssetBase = 'assets/images/app_assets';
const String _fallbackPrayerAsset = '$_appAssetBase/prayer_time.png';

class PrayerHeroCard extends StatelessWidget {
  const PrayerHeroCard({
    super.key,
    required this.day,
    required this.nextPrayer,
    required this.onTap,
    this.currentPrayer,
    this.exactAlarmPermission,
    this.subtitleOverride,
  });

  final PrayerDay? day;
  final NextPrayer? nextPrayer;
  final PrayerTimeEntry? currentPrayer;
  final PrayerExactAlarmPermissionStatus? exactAlarmPermission;
  final String? subtitleOverride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EquranColors colors = context.equranColors;
    final PrayerDay? prayerDay = day;
    final NextPrayer? next = nextPrayer;

    if (prayerDay == null || next == null) {
      return EquranGradientCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SizedBox(
          height: 176,
          child: Stack(
            children: <Widget>[
              const Positioned(
                right: -18,
                top: 8,
                bottom: 8,
                width: 190,
                child: _PrayerHeroDecoration(kind: PrayerTimeKind.fajr),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Prayer Times',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 230,
                      child: Text(
                        'Choose a location to show the next prayer time here.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onPrimaryMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Set up location',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w900,
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

    final PrayerTimeSettings settings = prayerDay.settings;
    final PrayerTimeEntry featuredPrayer = currentPrayer ?? next.entry;
    final String prayerTime = _formatTime(
      featuredPrayer.time,
      settings.use24HourFormat,
    );
    final String countdown = _formatCountdown(next.countdown);
    final bool exactAlarmDenied =
        exactAlarmPermission == PrayerExactAlarmPermissionStatus.denied;
    final String title = featuredPrayer.kind == PrayerTimeKind.sunrise
        ? 'Sunrise Time'
        : '${featuredPrayer.kind.label} Time';
    final String subtitle =
        subtitleOverride ?? '${next.entry.kind.label} begins in $countdown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 360;
            final bool use12HourTime = !settings.use24HourFormat;
            final double artWidth =
                (constraints.maxWidth * (compact ? 0.72 : 0.76))
                    .clamp(compact ? 220.0 : 270.0, compact ? 280.0 : 380.0)
                    .toDouble();
            final double trailingSpace = (artWidth * 0.72)
                .clamp(compact ? 178.0 : 220.0, compact ? 230.0 : 300.0)
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
              onTap: onTap,
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 20,
                compact ? 14 : 16,
                compact ? 12 : 16,
                compact ? 14 : 16,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    right: -20,
                    top: -24,
                    bottom: -12,
                    width: artWidth,
                    child: Transform.scale(
                      scale: compact ? 1.12 : 1.23,
                      alignment: Alignment.centerRight,
                      child: _PrayerHeroDecoration(kind: featuredPrayer.kind),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: compact ? 148.0 : 168.0,
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
                                    height: 0.94,
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
                                subtitle,
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
        ),
        if (exactAlarmDenied) ...<Widget>[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: colors.warningSurface,
              borderRadius: BorderRadius.circular(EquranRadii.medium),
              border: Border.all(color: colors.warning.withAlpha(72)),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.notifications_paused_outlined,
                  size: 18,
                  color: colors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Exact alarm permission is off. Prayer reminders may be delayed.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PrayerHeroDecoration extends StatelessWidget {
  const _PrayerHeroDecoration({required this.kind});

  final PrayerTimeKind kind;

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(4, 2, 0, 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  _prayerBannerAsset(kind),
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      _fallbackPrayerAsset,
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
  if (use24HourFormat) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String suffix = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${time.minute.toString().padLeft(2, '0')} $suffix';
}

String _formatCountdown(Duration duration) {
  final Duration normalized = duration.isNegative ? Duration.zero : duration;
  final int hours = normalized.inHours;
  final int minutes = normalized.inMinutes.remainder(60);
  if (hours <= 0) return '$minutes min';
  return '${hours}h ${minutes}m';
}
