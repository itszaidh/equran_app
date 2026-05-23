// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hifz_review_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HifzReviewLogAdapter extends TypeAdapter<HifzReviewLog> {
  @override
  final int typeId = 3;

  @override
  HifzReviewLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HifzReviewLog()
      ..surah = fields[0] as int
      ..ayah = fields[1] as int
      ..rating = fields[2] as String
      ..reviewedAt = fields[3] as DateTime
      ..previousInterval = fields[4] as int
      ..newInterval = fields[5] as int
      ..previousEaseFactor = fields[6] as double
      ..newEaseFactor = fields[7] as double;
  }

  @override
  void write(BinaryWriter writer, HifzReviewLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.surah)
      ..writeByte(1)
      ..write(obj.ayah)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.reviewedAt)
      ..writeByte(4)
      ..write(obj.previousInterval)
      ..writeByte(5)
      ..write(obj.newInterval)
      ..writeByte(6)
      ..write(obj.previousEaseFactor)
      ..writeByte(7)
      ..write(obj.newEaseFactor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HifzReviewLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
