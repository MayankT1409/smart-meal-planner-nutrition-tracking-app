import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'core/theme.dart';
import 'widgets/main_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive and register adapters via HiveService
  await HiveService.init();
  
  // Seed initial dummy data if boxes are empty
  await HiveService.seedDummyData();

  runApp(
    const ProviderScope(
      child: SmartMealApp(),
    ),
  );
}

class SmartMealApp extends StatelessWidget {
  const SmartMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationBar(),
    );
  }
}
