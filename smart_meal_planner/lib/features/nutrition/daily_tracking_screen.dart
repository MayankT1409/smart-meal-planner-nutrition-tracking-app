import 'package:flutter/material.dart';

class DailyTrackingScreen extends StatelessWidget {
  const DailyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressSection(context),
            const SizedBox(height: 24),
            const Text(
              'Nutrients Breakout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildNutrientRow(context, 'Protein', '80g / 120g', 0.65, Colors.blue),
            _buildNutrientRow(context, 'Carbs', '150g / 250g', 0.6, Colors.orange),
            _buildNutrientRow(context, 'Fats', '45g / 70g', 0.64, Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Water Intake',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildWaterTracker(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calories Remaining',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Text(
                  '1,250 kcal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Goal: 2,500 kcal',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              value: 0.5,
              strokeWidth: 10,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(
    BuildContext context,
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(8, (index) {
            final isFilled = index < 4;
            return Icon(
              Icons.local_drink,
              color: isFilled ? Colors.blue : Colors.grey[300],
            );
          }),
        ),
      ),
    );
  }
}
