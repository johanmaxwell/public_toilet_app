import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';

class FirestoreUsageMonitor {
  static final FirestoreUsageMonitor _instance =
      FirestoreUsageMonitor._internal();

  factory FirestoreUsageMonitor() {
    return _instance;
  }

  FirestoreUsageMonitor._internal() {
    _setupTerminationListener();
  }

  String _companyId = 'default';
  int _reads = 0;
  int _writes = 0;
  Timer? _flushTimer;

  void _setupTerminationListener() {
    _flushTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      flushToFirestore();
    });

    // Add process termination listener
    ProcessSignal.sigterm.watch().listen((_) {
      dispose();
    });
  }

  void updateCompanyId(String company) {
    _companyId = company;
  }

  void incrementReads([int count = 1]) {
    _reads += count;
  }

  void incrementWrites([int count = 1]) {
    _writes += count;
  }

  Future<void> flushToFirestore() async {
    // Don't flush if companyId is still default
    if (_companyId == 'default') return;

    if (_reads == 0 && _writes == 0) return;

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final usageRef = FirebaseFirestore.instance
          .collection('usage_metrics')
          .doc(_companyId)
          .collection('daily')
          .doc(today);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(usageRef);
        if (!snapshot.exists) {
          transaction.set(usageRef, {'reads': 0, 'writes': 0});
        }
        transaction.update(usageRef, {
          'reads': FieldValue.increment(_reads),
          'writes': FieldValue.increment(_writes),
        });
      });

      _reads = 0;
      _writes = 0;
    } catch (e) {
      print('Error flushing usage data: $e');
    }
  }

  Future<void> dispose() async {
    _flushTimer?.cancel();
    // Make sure to wait for the final flush to complete
    await flushToFirestore();
  }
}
