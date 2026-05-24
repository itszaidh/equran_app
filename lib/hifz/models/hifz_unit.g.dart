// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hifz_unit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HifzUnitAdapter extends TypeAdapter<HifzUnit> {
  @override
  final int typeId = 4;

  @override
  HifzUnit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HifzUnit()
      ..id = fields[0] as String
      ..unitType = fields[1] as String
      ..unitNumber = fields[2] as int
      ..frontierSurah = fields[3] as int
      ..frontierAyah = fields[4] as int
      ..startedAt = fields[5] as DateTime
      ..completedAt = fields[6] as DateTime?
      ..isComplete = fields[7] as bool;
  }

  @override
  void write(BinaryWriter writer, HifzUnit obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.unitType)
      ..writeByte(2)
      ..write(obj.unitNumber)
      ..writeByte(3)
      ..write(obj.frontierSurah)
      ..writeByte(4)
      ..write(obj.frontierAyah)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.isComplete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HifzUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
