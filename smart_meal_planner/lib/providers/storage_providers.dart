import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final nutritionGoalProvider = StateProvider<NutritionGoal?>((ref) {
  return ref.watch(localRepositoryProvider).getNutritionGoal();
});
