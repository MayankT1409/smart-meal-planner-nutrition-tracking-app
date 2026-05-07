import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/local_repository.dart';
import '../models/meal_entry.dart';
import '../models/nutrition_goal.dart';

final localRepositoryProvider = Provider((ref) => LocalRepository());

final mealEntriesProvider = StateNotifierProvider<MealEntriesNotifier, List<MealEntry>>((ref) {
  return MealEntriesNotifier(ref.watch(localRepositoryProvider));
});

class MealEntriesNotifier extends StateNotifier<List<MealEntry>> {
  final LocalRepository _repo;

  MealEntriesNotifier(this._repo) : super(_repo.getMealEntries());

  Future<void> addEntry(MealEntry entry) async {
    await _repo.logMeal(entry);
    state = _repo.getMealEntries();
  }

  Future<void> deleteEntry(int index) async {
    await _repo.removeMealEntry(index);
    state = _repo.getMealEntries();
  }
}

final nutritionGoalProvider = StateNotifierProvider<GoalNotifier, NutritionGoal?>((ref) {
  return GoalNotifier(ref.watch(localRepositoryProvider));
});

class GoalNotifier extends StateNotifier<NutritionGoal?> {
  final LocalRepository _repo;

  GoalNotifier(this._repo) : super(_repo.getNutritionGoal());

  Future<void> updateGoal(NutritionGoal goal) async {
    await _repo.updateNutritionGoal(goal);
    state = goal;
  }
}

final dailyTotalsProvider = Provider<Map<String, double>>((ref) {
  final entries = ref.watch(mealEntriesProvider);
  final today = DateTime.now();
  
  final todayEntries = entries.where((e) => 
    e.dateTime.year == today.year && 
    e.dateTime.month == today.month && 
    e.dateTime.day == today.day
  );

  double totalCals = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFats = 0;

  for (var entry in todayEntries) {
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
});

final weeklyAnalyticsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final entries = ref.watch(mealEntriesProvider);
  final now = DateTime.now();
  
  return List.generate(7, (index) {
    final date = now.subtract(Duration(days: 6 - index));
    final dayEntries = entries.where((e) => 
      e.dateTime.year == date.year && 
      e.dateTime.month == date.month && 
      e.dateTime.day == date.day
    );

    double totalCals = 0;
    for (var entry in dayEntries) {
      totalCals += entry.calories;
    }

    return {
      'day': DateFormat('E').format(date),
      'calories': totalCals,
    };
  });
});
