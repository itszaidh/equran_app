import 'package:flutter/material.dart';
import 'package:equran/theme/equran_colors.dart';
import 'package:equran/utils/app_radii.dart';
import 'package:equran/hifz/hifz_db.dart';
import 'package:equran/hifz/models/hifz_unit.dart';
import 'hifz_session_page.dart';
import 'package:equran/l10n/app_localizations.dart';

class HifzCompleteScreen extends StatefulWidget {
  final Map<String, int> ratingCounts;
  final Duration sessionDuration;
  final int totalReviewed;
  final int newGraduated;
  final HifzUnit unit;

  const HifzCompleteScreen({
    required this.ratingCounts,
    required this.sessionDuration,
    required this.totalReviewed,
    required this.newGraduated,
    required this.unit,
    super.key,
  });

  @override
  State<HifzCompleteScreen> createState() => _HifzCompleteScreenState();
}

class _HifzCompleteScreenState extends State<HifzCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _sessionSubtitle(AppLocalizations l10n) {
    final mins = widget.sessionDuration.inMinutes;
    if (mins < 1) return l10n.hifzCompleteSubtitleUnderMinute;
    return l10n.hifzCompleteSubtitleMinutes(mins);
  }

  String _retentionLabel() {
    final total = widget.ratingCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return '—';
    final positive =
        (widget.ratingCounts['good'] ?? 0) +
        (widget.ratingCounts['easy'] ?? 0) +
        (widget.ratingCounts['pass'] ?? 0) +
        (widget.ratingCounts['gotIt'] ?? 0);
    final pct = (positive / total * 100).toStringAsFixed(0);
    return '$pct%';
  }

  String _nextDueLabel(AppLocalizations l10n) {
    final due = HifzDB.getDueEntries();
    if (due.isEmpty) return l10n.hifzCompleteAllCaughtUp;
    final next = due.first.dueDate;
    final diff = next.difference(DateTime.now()).inDays;
    if (diff <= 0) return l10n.hifzCompleteNextDueToday;
    if (diff == 1) return l10n.hifzCompleteNextDueTomorrow;
    return l10n.hifzCompleteNextDueInDays(diff);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.equranColors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tryAgainLabel = 'Try again';
    final gotItLabel = 'Got it';
    final failLabel = 'Fail';
    final passLabel = 'Pass';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // COMPLETION ICON
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, value, child) => Transform.scale(
                  scale: value,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: colors.mint,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.primary, width: 2),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colors.primary,
                      size: 52,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // TITLE
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.3, 1.0),
                ),
                child: Text(
                  l10n.hifzCompleteTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              // SUBTITLE
              Text(
                _sessionSubtitle(l10n),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),
              if (widget.unit.isComplete)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primaryGradientStart,
                        colors.primaryGradientEnd,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    border: Border.all(
                      color: colors.accentGold.withAlpha(102),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(
                        l10n.hifzUnitCompleteTitle(widget.unit.displayName),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.hifzUnitCompleteSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onPrimaryMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // STATS CARD
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.4, 1.0),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border, width: 1),
                    borderRadius: BorderRadius.circular(AppRadii.large),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.hifzCompleteSummaryTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: colors.divider, height: 1),
                      const SizedBox(height: 12),

                      // Row of 4 rating chips
                      Row(
                        children: [
                          _StatChip(
                            label: tryAgainLabel,
                            count: widget.ratingCounts['again'] ?? 0,
                            bgColor: colors.surfaceAlt,
                            textColor: colors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: gotItLabel,
                            count: widget.ratingCounts['gotIt'] ?? 0,
                            bgColor: colors.primary.withAlpha(31),
                            textColor: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: failLabel,
                            count: widget.ratingCounts['fail'] ?? 0,
                            bgColor: colors.warningSurface,
                            textColor: colors.warning,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: passLabel,
                            count: widget.ratingCounts['pass'] ?? 0,
                            bgColor: colors.mint,
                            textColor: colors.primary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Divider(color: colors.divider, height: 1),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.hifzCompleteTotalReviewed,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          Text(
                            l10n.hifzCompleteTotalReviewedValue(
                              widget.totalReviewed,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (widget.newGraduated > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.hifzCompleteGraduated,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            Text(
                              l10n.hifzCompleteGraduatedValue(
                                widget.newGraduated,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.hifzCompleteRetentionRate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          Text(
                            _retentionLabel(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.hifzCompleteNextDue,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          Text(
                            _nextDueLabel(l10n),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // MOTIVATIONAL HADITH SNIPPET
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.goldSoft,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(
                    color: colors.accentGold.withAlpha(102), // 40%
                    width: 1,
                  ),
                ),
                child: Text(
                  l10n.hifzCompleteHadith,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.warning,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // BUTTONS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  onPressed: () => Navigator.of(context).popUntil(
                    (route) => route.isFirst || route.settings.name == '/hifz',
                  ),
                  child: Text(
                    l10n.hifzCompleteBackButton,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              if (HifzDB.getDueEntries().isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => HifzSessionPage(unit: widget.unit),
                        ),
                      );
                    },
                    child: Text(
                      l10n.hifzCompleteKeepReviewing(
                        HifzDB.getDueEntries().length,
                      ),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color bgColor;
  final Color textColor;

  const _StatChip({
    required this.label,
    required this.count,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
