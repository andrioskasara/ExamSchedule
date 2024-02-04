import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../exam.dart';
import '../notification_controller.dart';
import 'calendar_screen.dart';
import '../widgets/exam_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final List<Exam> exams = [
    Exam(
        subject: 'Human-computer interaction design',
        date: DateTime(2024, 1, 31, 13, 30)),
    Exam(
        subject: 'Electronic and Mobile Commerce',
        date: DateTime(2024, 2, 2, 12)),
    Exam(
        subject: 'Implementation of Free and Open Source Systems',
        date: DateTime(2024, 2, 8, 9)),
    Exam(
        subject: 'Mobile Information Systems',
        date: DateTime(2024, 2, 5, 23)),
    Exam(
        subject: 'Introduction to Data Science',
        date: DateTime(2024, 2, 9, 17))
  ];

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceiveMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceiveMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreateMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayed);
    _scheduleNotificationsForExistingExams();
  }

  void _scheduleNotificationsForExistingExams() {
    for (int i = 0; i < exams.length; i++) {
      _scheduleNotification(exams[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exams',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.currentUser != null
                ? _addExamFunction(context)
                : _navigateToSignInPage(context),
          ),
          IconButton(
            icon: const Icon(Icons.login, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        //physics: const ScrollPhysics(),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final subject = exams[index].subject;
          final date = exams[index].date;

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    date.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendar',
        onPressed: () async {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CalendarScreen(
                exams: exams,
              ),
            ),
          );
        },
        child: const Icon(Icons.calendar_month),
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void _navigateToSignInPage(BuildContext context) {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  Future<void> _addExamFunction(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: ExamWidget(
              addNewExam: _addExam,
            ),
          );
        });
  }

  void _addExam(Exam exam) {
    setState(() {
      exams.add(exam);
      _scheduleNotification(exam);
    });
  }

  void _scheduleNotification(Exam exam) {
    final int notificationId = exams.indexOf(exam);

    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notificationId,
            channelKey: "basic_channel",
            title: exam.subject,
            body: "You have an exam tomorrow!"),
        schedule: NotificationCalendar(
            day: exam.date.subtract(const Duration(days: 1)).day,
            month: exam.date.subtract(const Duration(days: 1)).month,
            year: exam.date.subtract(const Duration(days: 1)).year,
            hour: exam.date.subtract(const Duration(days: 1)).hour,
            minute: exam.date.subtract(const Duration(days: 1)).minute));
  }
}
