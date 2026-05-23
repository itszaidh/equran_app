// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hifz_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HifzEntryAdapter extends TypeAdapter<HifzEntry> {
  @override
  final int typeId = 20;

  @override
  HifzEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HifzEntry(
      surah: fields[0] as int,
      ayah: fields[1] as int,
      status: fields[2] as String,
      interval: fields[3] as int,
      easeFactor: fields[4] as double,
      repetitions: fields[5] as int,
      dueDate: fields[6] as DateTime,
      lastReviewed: fields[7] as DateTime?,
      lapses: fields[8] as int,
      track: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HifzEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.surah)
      ..writeByte(1)
      ..write(obj.ayah)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.interval)
      ..writeByte(4)
      ..write(obj.easeFactor)
      ..writeByte(5)
      ..write(obj.repetitions)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.lastReviewed)
      ..writeByte(8)
      ..write(obj.lapses)
      ..writeByte(9)
      ..write(obj.track);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HifzEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HifzReviewLogAdapter extends TypeAdapter<HifzReviewLog> {
  @override
  final int typeId = 21;

  @override
  HifzReviewLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HifzReviewLog(
      surah: fields[0] as int,
      ayah: fields[1] as int,
      rating: fields[2] as String,
      reviewedAt: fields[3] as DateTime,
      previousInterval: fields[4] as int,
      newInterval: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HifzReviewLog obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.newInterval);
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
