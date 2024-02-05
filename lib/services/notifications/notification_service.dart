import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../models/exam.dart';
import '../../models/location.dart';
import '../locations/location_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  int idCount = 0;
  bool locationNotificationActive = false;
  Location location =
      Location("University", 42.004186212873655, 21.409531941596985);
  DateTime? lastNotificationTime;

  NotificationService() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (locationNotificationActive) {
        checkLocationAndNotify();
      }
    });
  }

  void scheduleNotificationsForExistingExams(exams) {
    for (int i = 0; i < exams.length; i++) {
      scheduleNotification(exams[i]);
    }
  }

  void scheduleNotification(Exam exam) {
    final int notificationId = idCount++;

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: "basic_channel",
        title: exam.subject,
        body: "You have an exam tomorrow!",
      ),
      schedule: NotificationCalendar(
        day: exam.date.subtract(const Duration(days: 1)).day,
        month: exam.date.subtract(const Duration(days: 1)).month,
        year: exam.date.subtract(const Duration(days: 1)).year,
        hour: exam.date.subtract(const Duration(days: 1)).hour,
        minute: exam.date.subtract(const Duration(days: 1)).minute,
      ),
    );
  }

  Future<void> toggleLocationNotification() async {
    locationNotificationActive = !locationNotificationActive;

    if (locationNotificationActive) {
      checkLocationAndNotify();
    }
  }

  Future<void> checkLocationAndNotify() async {
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      bool theSameLocation = false;

      LocationService().getCurrentLocation().then((value) {
        if ((value.latitude < location.latitude + 0.01 &&
                value.latitude > location.latitude - 0.01) &&
            (value.longitude < location.longitude + 0.01 &&
                value.longitude > location.longitude - 0.01)) {
          theSameLocation = true;
        }

        if (theSameLocation && canSendNotification()) {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: idCount++,
              channelKey: "basic_channel",
              title: "Notification!",
              body: "You have an exam soon!",
            ),
          );
          lastNotificationTime = DateTime.now();
        }
      });
    }
  }

  bool canSendNotification() {
    return lastNotificationTime == null ||
        DateTime.now().difference(lastNotificationTime!) >
            const Duration(minutes: 10);
  }
}
