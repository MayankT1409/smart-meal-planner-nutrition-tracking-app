import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/storage_providers.dart';
import 'add_meal_screen.dart';

class MealPlanningScreen extends ConsumerWidget {
  const MealPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealEntries = ref.watch(mealEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planning'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMealScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: mealEntries.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mealEntries.length,
              itemBuilder: (context, index) {
                final entry = mealEntries[index];
                return Dismissible(
                  key: Key(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(mealEntriesProvider.notifier).deleteEntry(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meal deleted')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getMealColor(entry.mealType).withOpacity(0.1),
                        child: Icon(_getMealIcon(entry.mealType), color: _getMealColor(entry.mealType)),
                      ),
                      title: Text(
                        entry.foodName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${entry.mealType} • ${DateFormat('jm').format(entry.dateTime)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.calories.toInt()} kcal',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'P: ${entry.protein.toInt()}g C: ${entry.carbs.toInt()}g F: ${entry.fats.toInt()}g',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddMealScreen(mealToEdit: entry),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No meals planned yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to start planning your diet',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String type) {
    switch (type) {
      case 'Breakfast': return Icons.breakfast_dining;
      case 'Lunch': return Icons.lunch_dining;
      case 'Dinner': return Icons.dinner_dining;
      default: return Icons.restaurant;
    }
  }

  Color _getMealColor(String type) {
    switch (type) {
      case 'Breakfast': return Colors.orange;
      case 'Lunch': return Colors.green;
      case 'Dinner': return Colors.blue;
      default: return Colors.purple;
    }
  }
}
