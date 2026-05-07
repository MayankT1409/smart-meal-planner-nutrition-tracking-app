import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'food_database';

  // Get all food items
  Stream<List<FoodItem>> getFoodItems() {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FoodItem(
          id: doc.id,
          name: data['name'] ?? '',
          calories: (data['calories'] ?? 0).toDouble(),
          protein: (data['protein'] ?? 0).toDouble(),
          carbs: (data['carbs'] ?? 0).toDouble(),
          fats: (data['fats'] ?? 0).toDouble(),
        );
      }).toList();
    });
  }

  // Add custom food
  Future<void> addFoodItem(FoodItem item) async {
    await _firestore.collection(collectionPath).add({
      'name': item.name,
      'calories': item.calories,
      'protein': item.protein,
      'carbs': item.carbs,
      'fats': item.fats,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Search food items by name
  Future<List<FoodItem>> searchFood(String query) async {
    if (query.isEmpty) return [];
    
    final result = await _firestore
        .collection(collectionPath)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return result.docs.map((doc) {
      final data = doc.data();
      return FoodItem(
        id: doc.id,
        name: data['name'] ?? '',
        calories: (data['calories'] ?? 0).toDouble(),
        protein: (data['protein'] ?? 0).toDouble(),
        carbs: (data['carbs'] ?? 0).toDouble(),
        fats: (data['fats'] ?? 0).toDouble(),
      );
    }).toList();
  }

  // Seed sample data
  Future<void> seedSampleFoods() async {
    final collection = _firestore.collection(collectionPath);
    final snapshot = await collection.limit(1).get();
    
    if (snapshot.docs.isEmpty) {
      final samples = [
        {'name': 'Rice (1 cup)', 'calories': 205, 'protein': 4.3, 'carbs': 45, 'fats': 0.4},
        {'name': 'Apple', 'calories': 95, 'protein': 0.5, 'carbs': 25, 'fats': 0.3},
        {'name': 'Banana', 'calories': 105, 'protein': 1.3, 'carbs': 27, 'fats': 0.4},
        {'name': 'Egg (Large)', 'calories': 78, 'protein': 6.3, 'carbs': 0.6, 'fats': 5.3},
        {'name': 'Bread (1 slice)', 'calories': 79, 'protein': 2.7, 'carbs': 15, 'fats': 1.0},
        {'name': 'Milk (1 cup)', 'calories': 149, 'protein': 7.7, 'carbs': 12, 'fats': 8.0},
        {'name': 'Chicken Breast', 'calories': 165, 'protein': 31, 'carbs': 0, 'fats': 3.6},
        {'name': 'Garden Salad', 'calories': 35, 'protein': 2, 'carbs': 7, 'fats': 0.2},
      ];

      for (var food in samples) {
        await collection.add(food);
      }
    }
  }
}
