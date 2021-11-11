import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future selectNotification(String payload) async {
    debugPrint("payload: $payload");
    //this will automatically open the app to the most recently displayed route, which is what we want so no changes here
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

  Future<void> showNotifications(int id) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      'Emergency Timer expires in 5 minutes.',
      'Remeber to check in before the timer expires.',
      platformChannelSpecifics,
      payload: 'Notification Payload',
    );
  }
  Future<void> cancelAllNotifications(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
