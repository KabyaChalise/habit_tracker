import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/pages/home_page.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();

  runApp(MultiProvider(
    providers: [
      // habit provider
      ChangeNotifierProvider(create: (context) => HabitDatabase()),
      // theme provider
      ChangeNotifierProvider(create: (context) => ThemeProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themedata,
    );
  }
}

// prepare heatmap data set
Map<DateTime, int> prepareHeatMapDataset(List<Habit> habits) {
  Map<DateTime, int> datasets = {};

  for (var habit in habits) {
    for (var date in habit.completedDays) {
      final normalizeDate = DateTime(date.year, date.month, date.day);
      if (datasets.containsKey(normalizeDate)) {
        datasets[normalizeDate] = datasets[normalizeDate]! + 1;
      } else {
        datasets[normalizeDate] = 1;
      }
    }
  }
  return datasets;
}
