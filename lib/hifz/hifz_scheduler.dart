import 'dart:math';

import 'models/hifz_entry.dart';
import 'models/hifz_review_log.dart';

class HifzScheduler {
  static const double _minEase = 1.3;
  static const double _maxEase = 2.5;
  static const double _hardPenalty = 0.15;
  static const double _easyBonus = 0.15;
  static const double _fuzzFactor = 0.05;

  // Maps rating string to SM-2 quality integer
  static int _qualityFromRating(String rating) {
    switch (rating) {
      case 'again':
        return 0;
      case 'hard':
        return 2;
      case 'good':
        return 3;
      case 'easy':
        return 5;
      default:
        return 3;
    }
  }

  // Derives track from interval
  static String _trackFromInterval(int interval) {
    if (interval <= 6) return 'sabaq';
    if (interval <= 20) return 'sabqi';
    return 'manzil';
  }

  // Applies fuzz to prevent card clustering
  static int _applyFuzz(int interval) {
    final fuzz = (Random().nextDouble() * 2 - 1) * interval * _fuzzFactor;
    return max(1, (interval + fuzz).round());
  }

  // Core review function — mutates and returns entry
  // Also returns the review log to be saved by caller
  static (HifzEntry, HifzReviewLog) review(HifzEntry entry, String rating) {
    final quality = _qualityFromRating(rating);
    final prevInterval = entry.interval;
    final prevEaseFactor = entry.easeFactor;

    if (quality < 3) {
      // Forgotten — reset
      entry.repetitions = 0;
      entry.interval = 1;
      entry.lapses += 1;
      entry.status = 'learning';
      entry.easeFactor = max(_minEase, entry.easeFactor - 0.2);
    } else {
      // Remembered — advance
      int newInterval;
      if (entry.repetitions == 0) {
        newInterval = 1;
      } else if (entry.repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (entry.interval * entry.easeFactor).round();
      }

      newInterval = _applyFuzz(newInterval);

      // Adjust ease factor
      double ef =
          entry.easeFactor +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

      if (rating == 'hard') ef -= _hardPenalty;
      if (rating == 'easy') ef += _easyBonus;

      entry.easeFactor = ef.clamp(_minEase, _maxEase);
      entry.interval = newInterval;
      entry.repetitions += 1;
      entry.status = newInterval >= 21 ? 'mastered' : 'review';
    }

    entry.track = _trackFromInterval(entry.interval);
    entry.dueDate = DateTime.now().add(Duration(days: entry.interval));
    entry.lastReviewed = DateTime.now();

    final log = HifzReviewLog()
      ..surah = entry.surah
      ..ayah = entry.ayah
      ..rating = rating
      ..reviewedAt = DateTime.now()
      ..previousInterval = prevInterval
      ..newInterval = entry.interval
      ..previousEaseFactor = prevEaseFactor
      ..newEaseFactor = entry.easeFactor;

    return (entry, log);
  }

  // Preview next intervals for all 4 ratings
  // without mutating the entry — used to show
  // projected intervals on rating buttons
  static Map<String, int> previewIntervals(HifzEntry entry) {
    final result = <String, int>{};
    for (final rating in ['again', 'hard', 'good', 'easy']) {
      final clone = HifzEntry()
        ..surah = entry.surah
        ..ayah = entry.ayah
        ..status = entry.status
        ..interval = entry.interval
        ..easeFactor = entry.easeFactor
        ..repetitions = entry.repetitions
        ..dueDate = entry.dueDate
        ..lastReviewed = entry.lastReviewed
        ..lapses = entry.lapses
        ..track = entry.track;
      final (updated, _) = review(clone, rating);
      result[rating] = updated.interval;
    }
    return result;
  }

  // Format interval for display on rating buttons
  // e.g. 1 → "1d", 7 → "1w", 30 → "1mo"
  static String formatInterval(int days) {
    if (days < 7) return '${days}d';
    if (days < 30) return '${(days / 7).round()}w';
    if (days < 365) return '${(days / 30).round()}mo';
    return '${(days / 365).round()}y';
  }

  // Call when an ayah completes a learn
  // phase repetition (not SM-2 review)
  // Returns true when entry is ready to
  // graduate from learning to review phase
  static bool recordLearnRepetition(HifzEntry entry) {
    entry.introducedRepetitions += 1;

    if (entry.introducedRepetitions >= 3) {
      // Graduate to SM-2 review phase
      entry.status = 'review';
      entry.repetitions = 1;
      entry.interval = 1;
      entry.dueDate = DateTime.now().add(const Duration(days: 1));
      return true; // graduated
    }
    // Stay in learning, due immediately
    entry.dueDate = DateTime.now();
    return false;
  }
}
