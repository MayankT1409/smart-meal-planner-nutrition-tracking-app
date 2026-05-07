import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/nutrition_goal.dart';
import '../../providers/storage_providers.dart';

class GoalSettingScreen extends ConsumerStatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  ConsumerState<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends ConsumerState<GoalSettingScreen> {
  late TextEditingController _calController;
  late TextEditingController _protController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    final currentGoal = ref.read(nutritionGoalProvider);
    _calController = TextEditingController(text: currentGoal?.targetCalories.toInt().toString() ?? '2000');
    _protController = TextEditingController(text: currentGoal?.targetProtein.toInt().toString() ?? '150');
    _carbController = TextEditingController(text: currentGoal?.targetCarbs.toInt().toString() ?? '200');
    _fatController = TextEditingController(text: currentGoal?.targetFats.toInt().toString() ?? '70');
  }

  @override
  void dispose() {
    _calController.dispose();
    _protController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    final newGoal = NutritionGoal(
      targetCalories: double.tryParse(_calController.text) ?? 2000,
      targetProtein: double.tryParse(_protController.text) ?? 150,
      targetCarbs: double.tryParse(_carbController.text) ?? 200,
      targetFats: double.tryParse(_fatController.text) ?? 70,
    );

    await ref.read(nutritionGoalProvider.notifier).updateGoal(newGoal);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals updated successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Nutrition Goals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Targets',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Define your ideal daily nutritional intake.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildGoalInput(
              _calController,
              'Calorie Goal',
              'kcal',
              Icons.local_fire_department,
              Colors.red,
            ),
            const SizedBox(height: 20),
            _buildGoalInput(
              _protController,
              'Protein Goal',
              'g',
              Icons.bolt,
              Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildGoalInput(
              _carbController,
              'Carbs Goal',
              'g',
              Icons.grain,
              Colors.orange,
            ),
            const SizedBox(height: 20),
            _buildGoalInput(
              _fatController,
              'Fats Goal',
              'g',
              Icons.water_drop,
              Colors.green,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _saveGoals,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Center(
                child: Text('Update My Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInput(
    TextEditingController controller,
    String label,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: unit,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
