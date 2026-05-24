// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hifz_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HifzEntryAdapter extends TypeAdapter<HifzEntry> {
  @override
  final int typeId = 2;

  @override
  HifzEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HifzEntry()
      ..surah = fields[0] as int
      ..ayah = fields[1] as int
      ..status = fields[2] as String
      ..interval = fields[3] as int
      ..easeFactor = fields[4] as double
      ..repetitions = fields[5] as int
      ..dueDate = fields[6] as DateTime
      ..lastReviewed = fields[7] as DateTime?
      ..lapses = fields[8] as int
      ..track = fields[9] as String
      ..unitId = fields[10] as String?
      ..sequenceIndex = fields[11] as int?
      ..introducedRepetitions = (fields[12] as int?) ?? 0
      ..firstLearnedAt = fields[13] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, HifzEntry obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.track)
      ..writeByte(10)
      ..write(obj.unitId)
      ..writeByte(11)
      ..write(obj.sequenceIndex)
      ..writeByte(12)
      ..write(obj.introducedRepetitions)
      ..writeByte(13)
      ..write(obj.firstLearnedAt);
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
