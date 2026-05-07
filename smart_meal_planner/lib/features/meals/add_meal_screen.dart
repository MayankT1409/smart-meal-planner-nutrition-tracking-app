import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/meal_entry.dart';
import '../../providers/storage_providers.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final MealEntry? mealToEdit;

  const AddMealScreen({super.key, this.mealToEdit});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  late TextEditingController _quantityController;
  
  String _selectedMealType = 'Breakfast';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mealToEdit?.foodName ?? '');
    _caloriesController = TextEditingController(text: widget.mealToEdit?.calories.toString() ?? '');
    _proteinController = TextEditingController(text: widget.mealToEdit?.protein.toString() ?? '');
    _carbsController = TextEditingController(text: widget.mealToEdit?.carbs.toString() ?? '');
    _fatsController = TextEditingController(text: widget.mealToEdit?.fats.toString() ?? '');
    _quantityController = TextEditingController(text: widget.mealToEdit?.quantity.toString() ?? '1');
    
    if (widget.mealToEdit != null) {
      _selectedMealType = widget.mealToEdit!.mealType;
      _selectedDate = widget.mealToEdit!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.mealToEdit!.dateTime);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final mealEntry = MealEntry(
        id: widget.mealToEdit?.id ?? const Uuid().v4(),
        mealType: _selectedMealType,
        foodName: _nameController.text,
        quantity: double.parse(_quantityController.text),
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fats: double.parse(_fatsController.text),
        dateTime: combinedDateTime,
      );

      final notifier = ref.read(mealEntriesProvider.notifier);
      
      if (widget.mealToEdit != null) {
        // For simplicity in this starter, we find the index and update
        // In a real app, you might use a more robust update method
        final entries = ref.read(mealEntriesProvider);
        final index = entries.indexWhere((e) => e.id == widget.mealToEdit!.id);
        if (index != -1) {
          await notifier.deleteEntry(index);
          await notifier.addEntry(mealEntry);
        }
      } else {
        await notifier.addEntry(mealEntry);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.mealToEdit != null ? 'Meal Updated' : 'Meal Added')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealToEdit != null ? 'Edit Meal' : 'Add Meal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMealType,
              decoration: const InputDecoration(labelText: 'Meal Type'),
              items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedMealType = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Food Name', hintText: 'e.g. Chicken Salad'),
              validator: (val) => val!.isEmpty ? 'Please enter food name' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(labelText: 'Calories', suffixText: 'kcal'),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Macros', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMacroField(_proteinController, 'Protein', 'g'),
                const SizedBox(width: 8),
                _buildMacroField(_carbsController, 'Carbs', 'g'),
                const SizedBox(width: 8),
                _buildMacroField(_fatsController, 'Fats', 'g'),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            ListTile(
              title: const Text('Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) setState(() => _selectedTime = picked);
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveMeal,
              child: Text(widget.mealToEdit != null ? 'Update Meal' : 'Save Meal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroField(TextEditingController controller, String label, String unit) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
