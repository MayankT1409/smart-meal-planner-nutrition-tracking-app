import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/storage_providers.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyData = ref.watch(weeklyAnalyticsProvider);
    final dailyTotals = ref.watch(dailyTotalsProvider);
    final goal = ref.watch(nutritionGoalProvider);

    final targetCals = goal?.targetCalories ?? 2000;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Weekly Calorie Trend'),
            const SizedBox(height: 16),
            _buildLineChart(context, weeklyData, targetCals),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _buildSectionTitle('Macronutrients')),
                Expanded(child: _buildSectionTitle('Goal Completion')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPieChart(context, dailyTotals)),
                const SizedBox(width: 16),
                Expanded(child: _buildGoalStats(context, dailyTotals, targetCals)),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Nutritional Insights'),
            const SizedBox(height: 16),
            _buildInsightCard(
              context,
              'Consistency',
              'You hit your calorie goal 5 out of the last 7 days. Keep it up!',
              Icons.trending_up,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              context,
              'Macro Balance',
              'Your protein intake is slightly low today. Consider adding some Greek yogurt or chicken.',
              Icons.lightbulb_outline,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLineChart(BuildContext context, List<Map<String, dynamic>> data, double target) {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 32, 32, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    return Text(data[value.toInt()]['day'], style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['calories'])).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
            // Target line
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), target)).toList(),
              isCurved: false,
              color: Colors.red.withOpacity(0.2),
              barWidth: 2,
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, Map<String, double> totals) {
    final protein = totals['protein']! * 4;
    final carbs = totals['carbs']! * 4;
    final fats = totals['fats']! * 9;
    final totalCalories = protein + carbs + fats;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: totalCalories == 0 
          ? const Center(child: Text('No data yet'))
          : PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                    value: protein,
                    title: 'P',
                    color: Colors.blue,
                    radius: 40,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: carbs,
                    title: 'C',
                    color: Colors.orange,
                    radius: 40,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: fats,
                    title: 'F',
                    color: Colors.green,
                    radius: 40,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGoalStats(BuildContext context, Map<String, double> totals, double target) {
    final progress = (totals['calories']! / target).clamp(0.0, 1.0);
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Text('Daily Goal', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String desc, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
