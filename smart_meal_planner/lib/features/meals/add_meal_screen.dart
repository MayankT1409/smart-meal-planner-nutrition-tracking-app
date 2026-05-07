import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/meal_entry.dart';
import '../../providers/storage_providers.dart';
import '../../services/offline_sync_service.dart';

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
  
  bool _isLoading = false;
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
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
        protein: double.tryParse(_proteinController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0,
        fats: double.tryParse(_fatsController.text) ?? 0,
        dateTime: combinedDateTime,
      );

      final notifier = ref.read(mealEntriesProvider.notifier);
      
      if (widget.mealToEdit != null) {
        final entries = ref.read(mealEntriesProvider);
        final index = entries.indexWhere((e) => e.id == widget.mealToEdit!.id);
        if (index != -1) {
          await notifier.deleteEntry(index);
          await notifier.addEntry(mealEntry);
        }
      } else {
        await notifier.addEntry(mealEntry);
      }

      // Local save is successful, now attempt background sync
      // We don't await this so it doesn't block the UI or show errors if Firebase fails
      OfflineSyncService.queueMealSync(mealEntry).catchError((e) {
        debugPrint('Background sync failed (will retry): $e');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal Logged Successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving meal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealToEdit != null ? 'Edit Meal' : 'Add New Meal'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildCardSection(
                  title: 'Basic Information',
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedMealType,
                      decoration: const InputDecoration(labelText: 'Meal Category'),
                      items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedMealType = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'What did you eat?',
                        hintText: 'e.g. Scrambled Eggs',
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter a food name';
                        if (val.length < 2) return 'Name too short';
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCardSection(
                  title: 'Nutrition Details',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _caloriesController,
                            decoration: const InputDecoration(labelText: 'Calories', suffixText: 'kcal'),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              final n = double.tryParse(val);
                              if (n == null || n < 0) return 'Invalid';
                              if (n > 5000) return 'Too high?';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(labelText: 'Quantity', suffixText: 'serv'),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              final n = double.tryParse(val);
                              if (n == null || n <= 0) return 'Must be > 0';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Macronutrients (Optional)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMacroField(_proteinController, 'Protein', Colors.blue),
                        const SizedBox(width: 8),
                        _buildMacroField(_carbsController, 'Carbs', Colors.orange),
                        const SizedBox(width: 8),
                        _buildMacroField(_fatsController, 'Fats', Colors.green),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCardSection(
                  title: 'Time & Date',
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Schedule Date'),
                      subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
                      trailing: const Icon(Icons.calendar_month),
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
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Logged Time'),
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
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveMeal,
                  child: Text(widget.mealToEdit != null ? 'Apply Changes' : 'Confirm & Save'),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCardSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildMacroField(TextEditingController controller, String label, Color color) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: '0',
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
