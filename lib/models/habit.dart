import 'package:isar/isar.dart';

part 'habit.g.dart';

@Collection()
class Habit {
  // id
  Id id = Isar.autoIncrement;

  // habit name
  late String name;

  // complete day
  List<DateTime> completedDays = [
    // DateTime(years,months,days)
  ];
}
