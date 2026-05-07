import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../meals/add_meal_screen.dart';
import '../../providers/storage_providers.dart';
import '../../models/meal_entry.dart';
import '../../services/offline_sync_service.dart';

class FoodEntryScreen extends ConsumerWidget {
  const FoodEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentEntries = ref.watch(mealEntriesProvider).reversed.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Add'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log your meal in seconds',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'Scan Barcode',
                    Icons.barcode_reader,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'My Meals',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'One-Tap Re-Add',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (recentEntries.isEmpty)
              _buildEmptyState(context)
            else
              ...recentEntries.map((meal) => _buildQuickAddCard(context, ref, meal)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMealScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Custom Meal'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('No recent meals found.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQuickAddCard(BuildContext context, WidgetRef ref, MealEntry meal) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Quick-add as ${meal.mealType}'),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
        ),
        onTap: () async {
          // CLONE AND ADD IMMEDIATELY
          final newEntry = MealEntry(
            id: const Uuid().v4(),
            mealType: meal.mealType,
            foodName: meal.foodName,
            quantity: meal.quantity,
            calories: meal.calories,
            protein: meal.protein,
            carbs: meal.carbs,
            fats: meal.fats,
            dateTime: DateTime.now(), // Use current time
          );

          await ref.read(mealEntriesProvider.notifier).addEntry(newEntry);
          
          // Sync to Firebase in background
          OfflineSyncService.queueMealSync(newEntry).catchError((_) {});

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Quickly Added: ${meal.foodName}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
