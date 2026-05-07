import '../models/food_item.dart';
import '../models/meal_entry.dart';
import '../models/nutrition_goal.dart';
import 'hive_service.dart';

class LocalRepository {
  // Food Items
  List<FoodItem> getAvailableFoods() {
    return HiveService.getAllFood();
  }

  Future<void> saveFoodItem(FoodItem item) async {
    await HiveService.addFood(item);
  }

  // Meal Entries
  List<MealEntry> getMealEntries() {
    return HiveService.getMealEntries();
  }

  Future<void> logMeal(MealEntry entry) async {
    await HiveService.addMealEntry(entry);
  }

  Future<void> removeMealEntry(int index) async {
    await HiveService.deleteMealEntry(index);
  }

  // Nutrition Goals
  NutritionGoal? getNutritionGoal() {
    return HiveService.getGoal();
  }

  Future<void> updateNutritionGoal(NutritionGoal goal) async {
    await HiveService.saveGoal(goal);
  }
  
  // Calculate Daily Totals
  Map<String, double> calculateDailyTotals(DateTime date) {
    final entries = getMealEntries().where((e) => 
      e.dateTime.year == date.year && 
      e.dateTime.month == date.month && 
      e.dateTime.day == date.day
    );

    double totalCals = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var entry in entries) {
      totalCals += entry.calories;
      totalProtein += entry.protein;
      totalCarbs += entry.carbs;
      totalFats += entry.fats;
    }

    return {
      'calories': totalCals,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }
}
