import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  // Set Up
  // Initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar =
        await Isar.open([HabitSchema, AppSettingsSchema], directory: dir.path);
  }

  // Save first date of app startup for heatmap
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findAll();
    if (existingSettings.isEmpty) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // Get first date of app startup for heatmap
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  // CRUD Operation
  // list of habit
  final List<Habit> currentHabits = [];
  // Create
  Future<void> addHabit(String habitName) async {
    // create
    final newHabit = Habit()..name = habitName;
    // save
    await isar.writeTxn(() => isar.habits.put(newHabit));
    //re read
    readHabits();
  }

  // Read
  Future<void> readHabits() async {
    // fetch
    List<Habit> fetchHabit = await isar.habits.where().findAll();
    // give to current habit
    currentHabits.clear();
    currentHabits.addAll(fetchHabit);
    // update ui
    notifyListeners();
  }

  // Update on and off
  Future<void> updateHabitCompletion(int id, bool isComplete) async {
    // find specific habit
    final habit = await isar.habits.get(id);
    // update completion status
    if (habit != null) {
      await isar.writeTxn(() async {
        // if habit complete add current date to completeDays list
        if (isComplete && !habit.completedDays.contains(DateTime.now())) {
          // today
          final today = DateTime.now();
          // add current date if not already added
          habit.completedDays.add(DateTime(
            today.year,
            today.month,
            today.day,
          ));
        }
        // if habit not complete remove the current date from the list
        else {
          // remove the current date if the habit is marked as not complete
          habit.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        // save the update
        await isar.habits.put(habit);
      });
    }
    // re read db
    readHabits();
  }

  // Update name
  Future<void> updateHabitName(int id, String newName) async {
    // find
    final habit = await isar.habits.get(id);
    // update
    if (habit != null) {
      await isar.writeTxn(() async {
        // assign
        habit.name = newName;
        // save
        await isar.habits.put(habit);
      });
    }
    // re read
    readHabits();
  }

  // Delete
  Future<void> deleteHabit(int id) async {
    // delete
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    // re read
    readHabits();
  }
}
