import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_item.dart';
import '../models/meal_entry.dart';
import '../models/nutrition_goal.dart';
import '../models/daily_nutrition_summary.dart';

class HiveService {
  static const String foodBoxName = 'food_items';
  static const String mealBoxName = 'meal_entries';
  static const String goalBoxName = 'nutrition_goals';
  static const String summaryBoxName = 'daily_summaries';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(FoodItemAdapter());
    Hive.registerAdapter(MealEntryAdapter());
    Hive.registerAdapter(NutritionGoalAdapter());
    Hive.registerAdapter(DailyNutritionSummaryAdapter());

    // Open Boxes
    await Hive.openBox<FoodItem>(foodBoxName);
    await Hive.openBox<MealEntry>(mealBoxName);
    await Hive.openBox<NutritionGoal>(goalBoxName);
    await Hive.openBox<DailyNutritionSummary>(summaryBoxName);
    await Hive.openBox('sync_queue');
  }

  // Generic CRUD helpers
  static Box<T> getBox<T>(String name) => Hive.box<T>(name);

  // Food Item Operations
  static List<FoodItem> getAllFood() => getBox<FoodItem>(foodBoxName).values.toList();
  static Future<void> addFood(FoodItem item) => getBox<FoodItem>(foodBoxName).put(item.id, item);
  
  // Meal Entry Operations
  static List<MealEntry> getMealEntries() => getBox<MealEntry>(mealBoxName).values.toList();
  static Future<void> addMealEntry(MealEntry entry) => getBox<MealEntry>(mealBoxName).add(entry);
  static Future<void> deleteMealEntry(int index) => getBox<MealEntry>(mealBoxName).deleteAt(index);

  // Nutrition Goal
  static NutritionGoal? getGoal() => getBox<NutritionGoal>(goalBoxName).get('current_goal');
  static Future<void> saveGoal(NutritionGoal goal) => getBox<NutritionGoal>(goalBoxName).put('current_goal', goal);

  // Seed Dummy Data
  static Future<void> seedDummyData() async {
    final foodBox = getBox<FoodItem>(foodBoxName);
    if (foodBox.isEmpty) {
      final dummyFood = [
        FoodItem(id: '1', name: 'Apple', calories: 95, protein: 0.5, carbs: 25, fats: 0.3),
        FoodItem(id: '2', name: 'Chicken Breast (100g)', calories: 165, protein: 31, carbs: 0, fats: 3.6),
        FoodItem(id: '3', name: 'Brown Rice (1 cup)', calories: 218, protein: 4.5, carbs: 46, fats: 1.6),
        FoodItem(id: '4', name: 'Greek Yogurt', calories: 100, protein: 10, carbs: 4, fats: 5),
        FoodItem(id: '5', name: 'Almonds (28g)', calories: 164, protein: 6, carbs: 6, fats: 14),
      ];
      for (var food in dummyFood) {
        await foodBox.put(food.id, food);
      }
    }

    final goalBox = getBox<NutritionGoal>(goalBoxName);
    if (goalBox.isEmpty) {
      await saveGoal(NutritionGoal(
        targetCalories: 2000,
        targetProtein: 150,
        targetCarbs: 200,
        targetFats: 70,
      ));
    }
  }
}
