import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:public_app/pages/gender_selection_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  await _initNotifications();

  runApp(const PublicApp());
}

Future<void> _initNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  if (Platform.isIOS) {
    await messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    AppleNotification? apple = message.notification?.apple;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android:
              android != null
                  ? AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    channelDescription: channel.description,
                    icon: android.smallIcon ?? '@mipmap/ic_launcher',
                    importance: Importance.max,
                    priority: Priority.high,
                  )
                  : null,
          iOS:
              apple != null
                  ? const DarwinNotificationDetails(
                    presentAlert: true,
                    presentBadge: true,
                    presentSound: true,
                  )
                  : null,
        ),
      );
    }
  });
}

class PublicApp extends StatelessWidget {
  const PublicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toilet Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: GenderSelectionPage(),
    );
  }
}
