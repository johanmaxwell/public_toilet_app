import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:public_app/pages/company_selection/company_selection.dart';
import 'package:public_app/utils/firebase_usage_monitor.dart';
import 'firebase_options.dart';
import 'package:public_app/utils/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await FirebaseAuth.instance.signInAnonymously();
  await NotificationService.init();

  final usageMonitor = FirestoreUsageMonitor();

  runApp(PublicApp(usageMonitor: usageMonitor));
}

class PublicApp extends StatefulWidget {
  final FirestoreUsageMonitor usageMonitor;

  const PublicApp({super.key, required this.usageMonitor});

  @override
  State<PublicApp> createState() => _PublicAppState();
}

class _PublicAppState extends State<PublicApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.usageMonitor.flushToFirestore();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      widget.usageMonitor.flushToFirestore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toilet Monitoring',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: CompanySelectionPage(),
    );
  }
}
