import 'package:flutter/material.dart';

class MealPlanningScreen extends StatelessWidget {
  const MealPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planning'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlanCard(
            context,
            'Breakfast',
            'Oatmeal with Berries',
            '8:00 AM',
            Icons.breakfast_dining,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            context,
            'Lunch',
            'Grilled Chicken Salad',
            '1:00 PM',
            Icons.lunch_dining,
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            context,
            'Dinner',
            'Baked Salmon with Quinoa',
            '7:30 PM',
            Icons.dinner_dining,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add New Meal Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String title,
    String meal,
    String time,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(meal),
        trailing: Text(
          time,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
