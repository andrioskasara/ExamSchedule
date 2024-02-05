import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exam.dart';

class ExamWidget extends StatefulWidget {
  final Function(Exam) addNewExam;

  const ExamWidget({required this.addNewExam, super.key});

  @override
  ExamWidgetState createState() => ExamWidgetState();
}

class ExamWidgetState extends State<ExamWidget> {
  final TextEditingController courseController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white60,
      height: 380,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: 'Course')),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                ElevatedButton(
                  child: const Text('Select Date'),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Time: ${selectedDate.toLocal().toString().split(' ')[1].substring(0, 5)}'),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: const Text('Select Time'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                  child: const Text('Add Exam'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? chosenDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2090),
    );

    if (chosenDate != null && chosenDate != selectedDate) {
      setState(() {
        selectedDate = chosenDate;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? chosenTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    if (chosenTime != null && chosenTime != selectedTime) {
      setState(() {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          chosenTime.hour,
          chosenTime.minute,
        );
      });
    }
  }

  void _submitData() async {
    Exam exam = Exam(
      subject: courseController.text,
      date: selectedDate,
    );
    widget.addNewExam(exam);
    Navigator.pop(context);
  }
}
