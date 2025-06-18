import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:public_app/models/toilet_data.dart';
import 'package:public_app/utils/string_util.dart';

class RemindMeButton extends StatelessWidget {
  final String gender;
  final String company;
  final String? selectedGedung;
  final QuerySnapshot snapshot;

  const RemindMeButton({
    super.key,
    required this.company,
    required this.gender,
    required this.selectedGedung,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor:
                gender == 'pria' ? Colors.purpleAccent : Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => _showRemindMePopup(context),
          child: const Text(
            "Remind Me",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showRemindMePopup(BuildContext context) {
    final toiletFull = getToiletFull(snapshot);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedToilet;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SizedBox(
                height: 500,
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Text(
                        "Pilih toilet:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Expanded(
                        child:
                            toiletFull.isNotEmpty
                                ? SingleChildScrollView(
                                  child: Column(
                                    children:
                                        toiletFull.map((floor) {
                                          return RadioListTile<String>(
                                            title: Text(
                                              StringUtil.snakeToCapitalized(
                                                floor,
                                              ),
                                            ),
                                            value: floor,
                                            groupValue: selectedToilet,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedToilet = value;
                                              });
                                            },
                                          );
                                        }).toList(),
                                  ),
                                )
                                : Center(
                                  child: Text(
                                    'Tidak ada toilet yang penuh 🙏',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (selectedToilet != null) {
                              final fcmToken =
                                  await FirebaseMessaging.instance.getToken();

                              await FirebaseFirestore.instance
                                  .collection('reminders')
                                  .add({
                                    'fcm_token': fcmToken,
                                    'gedung': selectedGedung,
                                    'lokasi': selectedToilet,
                                    'gender': gender,
                                    'company': company,
                                    'timestamp': FieldValue.serverTimestamp(),
                                  });

                              if (!context.mounted) return;
                              Navigator.pop(context);
                              _showConfirmationDialog(context, selectedToilet!);
                            }
                          },
                          child: const Text(
                            "Select",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, String selectedToilet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.notifications_active, color: Colors.blue, size: 30),
              SizedBox(width: 8),
              Text(
                'Harap Menunggu!',
                style: TextStyle(color: Colors.lightGreen, fontSize: 25),
              ),
            ],
          ),
          content: Text(
            "Anda akan diberi notifikasi ketika toilet pada ${StringUtil.snakeToCapitalized(selectedToilet)} telah tersedia.",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<String> getToiletFull(QuerySnapshot snapshot) {
    final listToilet = <String, List<ToiletData>>{};

    for (var doc in snapshot.docs) {
      final data = ToiletData.fromFirestore(doc.data() as Map<String, dynamic>);
      listToilet.putIfAbsent(data.lokasi, () => []).add(data);
    }

    final toiletFull = <String>[];

    for (final entry in listToilet.entries) {
      final allOccupied = entry.value.every(
        (toilet) => toilet.status == 'occupied',
      );
      if (allOccupied) {
        toiletFull.add(entry.key);
      }
    }

    return toiletFull;
  }
}
