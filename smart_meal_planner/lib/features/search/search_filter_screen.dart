import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_item.dart';
import '../../services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final searchQueryProvider = StateProvider<String>((ref) => '');

final foodSearchProvider = FutureProvider<List<FoodItem>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final service = ref.watch(firebaseServiceProvider);
  return service.searchFood(query);
});

class SearchFilterScreen extends ConsumerWidget {
  const SearchFilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(foodSearchProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Database'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search for food (e.g. Apple, Rice)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          _buildFilterChips(),
          Expanded(
            child: searchResults.when(
              data: (foods) {
                if (foods.isEmpty && query.isNotEmpty) {
                  return const Center(child: Text('No food found. Try a different search!'));
                }
                if (foods.isEmpty) {
                  return _buildSampleSuggestions(ref);
                }
                return ListView.builder(
                  itemCount: foods.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return _buildFoodCard(context, foods[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFoodDialog(context, ref),
        label: const Text('Custom Food'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(label: const Text('High Protein'), onSelected: (b) {}),
          const SizedBox(width: 8),
          FilterChip(label: const Text('Low Carb'), onSelected: (b) {}),
          const SizedBox(width: 8),
          FilterChip(label: const Text('Vegan'), onSelected: (b) {}),
          const SizedBox(width: 8),
          FilterChip(label: const Text('Keto'), onSelected: (b) {}),
        ],
      ),
    );
  }

  Widget _buildSampleSuggestions(WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Quick Suggestions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['Rice', 'Apple', 'Banana', 'Egg', 'Chicken', 'Salad'].map((s) {
            return ActionChip(
              label: Text(s),
              onPressed: () => ref.read(searchQueryProvider.notifier).state = s,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFoodCard(BuildContext context, FoodItem food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Cals: ${food.calories} | P: ${food.protein}g | C: ${food.carbs}g | F: ${food.fats}g'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
          onPressed: () {
            // Logic to add this food to a meal entry could go here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added ${food.name} to meal selection')),
            );
          },
        ),
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Food'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: calCtrl, decoration: const InputDecoration(labelText: 'Calories'), keyboardType: TextInputType.number),
              TextField(controller: protCtrl, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
              TextField(controller: carbCtrl, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number),
              TextField(controller: fatCtrl, decoration: const InputDecoration(labelText: 'Fats (g)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final item = FoodItem(
                id: '',
                name: nameCtrl.text,
                calories: double.tryParse(calCtrl.text) ?? 0,
                protein: double.tryParse(protCtrl.text) ?? 0,
                carbs: double.tryParse(carbCtrl.text) ?? 0,
                fats: double.tryParse(fatCtrl.text) ?? 0,
              );
              await ref.read(firebaseServiceProvider).addFoodItem(item);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food added to database!')));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
