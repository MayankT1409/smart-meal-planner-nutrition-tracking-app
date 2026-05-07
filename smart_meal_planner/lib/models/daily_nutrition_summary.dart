import 'package:hive/hive.dart';

part 'daily_nutrition_summary.g.dart';

@HiveType(typeId: 4)
class DailyNutritionSummary extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double totalCalories;

  @HiveField(2)
  final double totalProtein;

  @HiveField(3)
  final double totalCarbs;

  @HiveField(4)
  final double totalFats;

  DailyNutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });
}
