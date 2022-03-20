import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:capstone/DurationPicker.dart';

class NotificationService {
  //singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');//default icon for now

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
    'channelId',
    'Timer Trigger Notification',
    channelDescription: 'Notifies users of impending Timer that is going to elapse soon',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  static const NotificationDetails platformChannelSpecifics = 
  NotificationDetails(
    android: _androidNotificationDetails); //this is an android only app, so it isnt't initialized for ios or mac

  Future<void> showNotifications(int id, Duration whenTimerExpires) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      'Emergency Timer expires in ${timerDurationFormat(whenTimerExpires)}.',
      'Remeber to check in before the timer expires.',
      platformChannelSpecifics,
      payload: 'Notification Payload',
    );
  }
  Future<void> cancelAllNotifications(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
