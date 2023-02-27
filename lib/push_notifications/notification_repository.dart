
import 'package:drivers_app/push_notifications/push_notification_system.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:drivers_app/global/global.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationRepository{

  FirebaseMessaging fcm = FirebaseMessaging.instance;


  AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel_2', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      // description
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true);



  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Map<String,dynamic>? notificationData;

  Future initialize() async {

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveNotification,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: null);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    onDidReceiveNotificationResponse: onSelectNotification
    );

    await fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );



    /// when app is closed/terminated state and it will be called only once
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print("OPENED FROM TERMINATED STATE :${message.data}");
        if(message.data['rideRequestId']!=null) {
          PushNotificationSystem.readUserRideRequestInformation(
              message.data['rideRequestId'],
              navigatorKey.currentState!.context);
        }
       // PushNotificationSystem.readUserRideRequestInformation(message.data['rideRequestId'], navigatorKey.currentState!.context);
      }
    });

    print("FCM is initialized");

    /// when app is open and notification came then this will be called
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {

      notificationData=message?.data;
      RemoteNotification? notification = message!.notification;

      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
         PushNotificationSystem.readUserRideRequestInformation(message.data['rideRequestId'], navigatorKey.currentState!.context);

        // flutterLocalNotificationsPlugin.show(
        //   notification.hashCode,
        //   notification.title,
        //   notification.body,
        //   NotificationDetails(
        //     android: AndroidNotificationDetails(
        //       channel.id,
        //       channel.name,
        //       playSound: true,
        //       priority: Priority.high,
        //       importance: Importance.high,
        //       icon: '@mipmap/ic_launcher',
        //       sound: const RawResourceAndroidNotificationSound('notification_sound'),
        //     ),
        //   ),
        // );
      }
    });

    /// when app is opened in background and user tap on notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("NOTIFICATION IS TAPPED AND GOT MESSAGE ${message.data}");
      if(message.data['rideRequestId']!=null) {
        PushNotificationSystem.readUserRideRequestInformation(
            message.data['rideRequestId'],
            navigatorKey.currentState!.context);
      }
    });
  }

  /// On android when app is open and user taps on notification
  Future<dynamic> onSelectNotification(NotificationResponse payload) async {
    print("Notification tapped when app is opened and id is ${notificationData?['rideRequestId']}");
   if(notificationData?['rideRequestId']!=null) {
     PushNotificationSystem.readUserRideRequestInformation(
         notificationData?['rideRequestId'],
         navigatorKey.currentState!.context);
   }
   }


  /// it will work for IOS when app in foreground
  _onDidReceiveNotification(int id, String? title, String? body, String? payload) async {
    print("NOTIFICATION RECEIVED");
  }

  Future generateAndGetToken() async
  {
    //richiedo il token
    String? registrationToken = await fcm.getToken();
    print("FCM Registration Token: ");
    print(registrationToken);

    //lo setto nel databese realtime
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    fcm.subscribeToTopic("allDrivers");
  }

}