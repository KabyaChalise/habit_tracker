import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/main.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // read existing habit on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  final TextEditingController habitController = TextEditingController();
  // create new habit
  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(),
              content: TextField(
                controller: habitController,
                decoration: const InputDecoration(
                  hintText: "Create new habit",
                ),
              ),
              actions: [
                // save
                MaterialButton(
                  onPressed: () {
                    // get habit name
                    String newHabitName = habitController.text;
                    // save db
                    context.read<HabitDatabase>().addHabit(newHabitName);
                    // pop box
                    Navigator.pop(context);
                    // clear controller
                    habitController.clear();
                  },
                  child: const Text("Save"),
                ),
                // cancel
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    habitController.clear();
                  },
                  child: const Text("Cancel"),
                )
              ],
            ));
  }

  // check habit on and off
  void checkHabitOnOff(bool? value, Habit habit) {
    // update habit completion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  // edit habit box
  void editHabitBox(Habit habit) {
    // set controller text to habit current name
    habitController.text = habit.name;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: habitController,
              ),
              actions: [
                // save
                MaterialButton(
                  onPressed: () {
                    // get habit name
                    String newHabitName = habitController.text;
                    // save db
                    context
                        .read<HabitDatabase>()
                        .updateHabitName(habit.id, newHabitName);
                    // pop box
                    Navigator.pop(context);
                    // clear controller
                    habitController.clear();
                  },
                  child: const Text("Save"),
                ),
                // cancel
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    habitController.clear();
                  },
                  child: const Text("Cancel"),
                )
              ],
            ));
  }

  // delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Are you sure you want to delete?"),
              actions: [
                // delete
                MaterialButton(
                  onPressed: () {
                    // save db
                    context.read<HabitDatabase>().deleteHabit(habit.id);
                    // pop box
                    Navigator.pop(context);
                  },
                  child: const Text("Delete"),
                ),
                // cancel
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewHabit,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
        body: ListView(
          children: [
            // heatmap
            _buildHeatMap(),

            // list view
            _buildHabitList(),
          ],
        ));
  }

  Widget _buildHeatMap() {
    // habit db
    final habitDatabase = context.watch<HabitDatabase>();
    // current habit
    List<Habit> currentHabit = habitDatabase.currentHabits;
    // build habit list
    return FutureBuilder<DateTime?>(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          // once date is avilable build heatmap
          if (snapshot.hasData) {
            return MyHeatMap(
                startDate: snapshot.data!,
                datasets: prepareHeatMapDataset(currentHabit));
          }
          //  if date not avilable
          else {
            return Container();
          }
        });
  }

  Widget _buildHabitList() {
    // habit db
    final habitDatabase = context.watch<HabitDatabase>();
    // current habit
    List<Habit> currentHabits = habitDatabase.currentHabits;
    // return habit list for ui
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentHabits.length,
        itemBuilder: (context, index) {
          // get each habit
          final habit = currentHabits[index];
          // check if complete today
          bool iscompletedToday = isHabitCompletedToday(habit.completedDays);
          // return habit
          return MyHabitTile(
            isCompleted: iscompletedToday,
            text: habit.name,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        });
  }
}
