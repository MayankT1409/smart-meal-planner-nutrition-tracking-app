import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/storage_providers.dart';
import 'add_meal_screen.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class MealPlanningScreen extends ConsumerWidget {
  const MealPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final allEntries = ref.watch(mealEntriesProvider);
    
    // Filter entries for the selected date
    final filteredEntries = allEntries.where((e) => 
      e.dateTime.year == selectedDate.year && 
      e.dateTime.month == selectedDate.month && 
      e.dateTime.day == selectedDate.day
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(context, selectedDate),
          Expanded(
            child: filteredEntries.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final meal = filteredEntries[index];
                      // Find actual index in original list for deletion
                      final originalIndex = allEntries.indexOf(meal);
                      return _buildMealCard(context, ref, meal, originalIndex);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMealScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isToday ? 'Today' : DateFormat('EEEE, MMM d').format(date),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (!isToday)
            TextButton(
              onPressed: () => ProviderScope.containerOf(context).read(selectedDateProvider.notifier).state = DateTime.now(),
              child: const Text('Back to Today'),
            ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, WidgetRef ref, dynamic meal, int index) {
    return Dismissible(
      key: Key(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Icon(_getIconForMealType(meal.mealType), size: 20),
          ),
          title: Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${meal.mealType} • ${DateFormat('h:mm a').format(meal.dateTime)}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${meal.calories.toInt()} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('P: ${meal.protein.toInt()} C: ${meal.carbs.toInt()} F: ${meal.fats.toInt()}', 
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMealScreen(mealToEdit: meal)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No meals logged for this day', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  IconData _getIconForMealType(String type) {
    switch (type) {
      case 'Breakfast': return Icons.coffee;
      case 'Lunch': return Icons.lunch_dining;
      case 'Dinner': return Icons.dinner_dining;
      default: return Icons.apple;
    }
  }
}
