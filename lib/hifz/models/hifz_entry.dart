import 'package:hive/hive.dart';

part 'hifz_entry.g.dart';

@HiveType(typeId: 2)
class HifzEntry extends HiveObject {
  @HiveField(0)
  late int surah;

  @HiveField(1)
  late int ayah;

  @HiveField(2)
  late String status; // 'new'|'learning'|'review'|'mastered'

  @HiveField(3)
  int interval = 0;

  @HiveField(4)
  double easeFactor = 2.5;

  @HiveField(5)
  int repetitions = 0;

  @HiveField(6)
  late DateTime dueDate;

  @HiveField(7)
  DateTime? lastReviewed;

  @HiveField(8)
  int lapses = 0;

  @HiveField(9)
  late String track; // 'sabaq'|'sabqi'|'manzil'

  @override
  String get key => '$surah:$ayah';

  bool get isDue =>
      dueDate.isBefore(DateTime.now().add(const Duration(hours: 1)));
}
