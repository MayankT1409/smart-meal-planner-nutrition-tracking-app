import 'package:hive/hive.dart';

part 'nutrition_goal.g.dart';

@HiveType(typeId: 3)
class NutritionGoal extends HiveObject {
  @HiveField(0)
  final double targetCalories;

  @HiveField(1)
  final double targetProtein;

  @HiveField(2)
  final double targetCarbs;

  @HiveField(3)
  final double targetFats;

  NutritionGoal({
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFats,
  });
}
