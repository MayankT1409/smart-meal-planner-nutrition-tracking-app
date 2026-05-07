import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'connectivity_service.dart';
import '../models/meal_entry.dart';

class OfflineSyncService {
  static const String queueBoxName = 'sync_queue';

  static Future<void> init() async {
    await Hive.openBox(queueBoxName);
  }

  // Queue a meal for syncing when back online
  static Future<void> queueMealSync(MealEntry entry) async {
    final box = Hive.box(queueBoxName);
    await box.add({
      'type': 'ADD_MEAL',
      'data': {
        'id': entry.id,
        'name': entry.foodName,
        'calories': entry.calories,
        'dateTime': entry.dateTime.toIso8601String(),
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Try syncing immediately if online
    if (await ConnectivityService.isConnected()) {
      await processQueue();
    }
  }

  // Process all pending actions
  static Future<void> processQueue() async {
    if (!await ConnectivityService.isConnected()) return;

    final box = Hive.box(queueBoxName);
    if (box.isEmpty) return;

    final firestore = FirebaseFirestore.instance;

    for (var key in box.keys) {
      final action = box.get(key);
      try {
        if (action['type'] == 'ADD_MEAL') {
          await firestore.collection('user_meal_logs').add(action['data']);
        }
        // If successful, remove from queue
        await box.delete(key);
      } catch (e) {
        // Retry later
        continue;
      }
    }
  }
}
