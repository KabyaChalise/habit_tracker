import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final void Function(bool?)? onChanged;
  final String text;
  final bool isCompleted;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;
  const MyHabitTile(
      {super.key,
      required this.isCompleted,
      required this.text,
      required this.onChanged,
      required this.editHabit,
      required this.deleteHabit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // edit
            SlidableAction(
              onPressed: editHabit,
              backgroundColor: Colors.grey.shade800,
              icon: Icons.settings,
            ),
            // delete
            SlidableAction(
              onPressed: deleteHabit,
              backgroundColor: Colors.red,
              icon: Icons.delete,
            )
          ],
        ),
        child: GestureDetector(
          onTap: () {
            if (onChanged != null) {
              onChanged!(!isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(7)),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(
                text,
                style: TextStyle(
                    color: isCompleted
                        ? Colors.white
                        : Theme.of(context).colorScheme.inversePrimary),
              ),
              leading: Checkbox(
                activeColor: Colors.green,
                value: isCompleted,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
