import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/storage_providers.dart';

class DailyTrackingScreen extends ConsumerWidget {
  const DailyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(dailyTotalsProvider);
    final goal = ref.watch(nutritionGoalProvider);
    
    // Default goal if none set
    final targetCals = goal?.targetCalories ?? 2000;
    final targetProtein = goal?.targetProtein ?? 150;
    final targetCarbs = goal?.targetCarbs ?? 200;
    final targetFats = goal?.targetFats ?? 70;

    final double caloriesRemaining = targetCals - totals['calories']!;
    final double calorieProgress = (totals['calories']! / targetCals).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainProgress(context, totals['calories']!, targetCals, calorieProgress),
            const SizedBox(height: 32),
            const Text(
              'Nutrient Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildNutrientCard(
              context,
              'Protein',
              totals['protein']!,
              targetProtein,
              Colors.blue,
              Icons.bolt,
            ),
            const SizedBox(height: 12),
            _buildNutrientCard(
              context,
              'Carbs',
              totals['carbs']!,
              targetCarbs,
              Colors.orange,
              Icons.grain,
            ),
            const SizedBox(height: 12),
            _buildNutrientCard(
              context,
              'Fats',
              totals['fats']!,
              targetFats,
              Colors.green,
              Icons.water_drop,
            ),
            const SizedBox(height: 32),
            _buildRemainingSection(context, caloriesRemaining),
          ],
        ),
      ),
    );
  }

  Widget _buildMainProgress(BuildContext context, double current, double target, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Calories',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${current.toInt()} / ${target.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'kcal consumed',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 90,
                width: 90,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(
    BuildContext context,
    String label,
    double current,
    double target,
    Color color,
    IconData icon,
  ) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '${current.toInt()}g / ${target.toInt()}g',
                  style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: color.withOpacity(0.1),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingSection(BuildContext context, double remaining) {
    final bool isOver = remaining < 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOver ? Colors.red[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            isOver ? 'Calories Over Limit' : 'Calories Remaining',
            style: TextStyle(
              color: isOver ? Colors.red : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${remaining.abs().toInt()} kcal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isOver ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
