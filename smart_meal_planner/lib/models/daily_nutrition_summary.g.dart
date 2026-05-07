// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_nutrition_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyNutritionSummaryAdapter extends TypeAdapter<DailyNutritionSummary> {
  @override
  final int typeId = 4;

  @override
  DailyNutritionSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyNutritionSummary(
      date: fields[0] as DateTime,
      totalCalories: fields[1] as double,
      totalProtein: fields[2] as double,
      totalCarbs: fields[3] as double,
      totalFats: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DailyNutritionSummary obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.totalCalories)
      ..writeByte(2)
      ..write(obj.totalProtein)
      ..writeByte(3)
      ..write(obj.totalCarbs)
      ..writeByte(4)
      ..write(obj.totalFats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyNutritionSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
