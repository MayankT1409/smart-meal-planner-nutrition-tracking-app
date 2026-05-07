import 'package:hive/hive.dart';

part 'food_item.g.dart';

@HiveType(typeId: 1)
class FoodItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double calories;

  @HiveField(3)
  final double protein;

  @HiveField(4)
  final double carbs;

  @HiveField(5)
  final double fats;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });
}
