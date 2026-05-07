import 'package:hive/hive.dart';

part 'meal_entry.g.dart';

@HiveType(typeId: 2)
class MealEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String mealType; // Breakfast, Lunch, Dinner, Snack

  @HiveField(2)
  final String foodName;

  @HiveField(3)
  final double quantity;

  @HiveField(4)
  final double calories;

  @HiveField(5)
  final double protein;

  @HiveField(6)
  final double carbs;

  @HiveField(7)
  final double fats;

  @HiveField(8)
  final DateTime dateTime;

  MealEntry({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.dateTime,
  });
}
