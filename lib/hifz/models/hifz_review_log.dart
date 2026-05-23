import 'package:hive/hive.dart';

part 'hifz_review_log.g.dart';

@HiveType(typeId: 3)
class HifzReviewLog extends HiveObject {
  @HiveField(0)
  late int surah;

  @HiveField(1)
  late int ayah;

  @HiveField(2)
  late String rating; // 'again'|'hard'|'good'|'easy'

  @HiveField(3)
  late DateTime reviewedAt;

  @HiveField(4)
  late int previousInterval;

  @HiveField(5)
  late int newInterval;

  @HiveField(6)
  late double previousEaseFactor;

  @HiveField(7)
  late double newEaseFactor;
}
