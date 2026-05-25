import 'package:equran/l10n/app_localizations_en.dart';
import 'package:equran/prayer/prayer_times_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats calm countdown labels without seconds', () {
    final AppLocalizationsEn localizations = AppLocalizationsEn();
    expect(
      formatPrayerCountdownLabel(
        const Duration(hours: 7, minutes: 12, seconds: 18),
        localizations,
      ),
      'In 7h 13m',
    );
    expect(
      formatPrayerCountdownLabel(
        const Duration(minutes: 42, seconds: 59),
        localizations,
      ),
      'In 43m',
    );
    expect(
      formatPrayerCountdownLabel(
        const Duration(minutes: 42),
        localizations,
      ),
      'In 42m',
    );
    expect(
      formatPrayerCountdownLabel(
        const Duration(minutes: 4, seconds: 59),
        localizations,
      ),
      'Very soon',
    );
    expect(
      formatPrayerCountdownLabel(
        Duration.zero,
        localizations,
      ),
      'Now',
    );
    expect(
      formatPrayerCountdownLabel(
        const Duration(minutes: 3),
        localizations,
        isNow: true,
      ),
      'Now',
    );
  });
}
