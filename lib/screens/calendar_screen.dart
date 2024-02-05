import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mis_lab3/models/exam.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import "package:collection/collection.dart";

class CalendarScreen extends StatefulWidget {
  final List<Exam> exams;

  const CalendarScreen({super.key, required this.exams});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final LinkedHashMap<DateTime, List<Exam>> _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: (DateTime key) {
        return key.day * 1000000 + key.month * 10000 + key.year;
      });
  late final ValueNotifier<List<Exam>> _selectedEvents;

  List<Exam> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }

    _selectedEvents.value = _getEventsForDay(selectedDay);
  }

  @override
  void initState() {
    super.initState();

    _events.addAll(groupBy(
        widget.exams,
        (exam) => DateTime(
              exam.date.year,
              exam.date.month,
              exam.date.day,
            )));
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2050, 1, 1),
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              onFormatChanged: (CalendarFormat calendarFormat) {
                setState(() {
                  _calendarFormat = calendarFormat;
                });
              },
              onPageChanged: (DateTime focusedDay) {
                _focusedDay = focusedDay;
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              eventLoader: _getEventsForDay,
            ),
            Expanded(
              child: ValueListenableBuilder<List<Exam>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(value[index].subject),
                          subtitle: Text(DateFormat("yyyy-MM-dd – kk:mm")
                              .format(value[index].date)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
