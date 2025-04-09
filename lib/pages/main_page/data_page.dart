// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:public_app/models/toilet_data.dart';
import 'package:public_app/pages/main_page/accordion_list.dart';
import 'package:public_app/pages/main_page/gedung_dropdown.dart';
import 'package:public_app/pages/main_page/header.dart';
import 'package:public_app/pages/main_page/remind_me.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key, required this.gender});
  final String gender;

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  String? selectedGedung;
  late Future<List<String>> gedungFuture;
  String? selectedRemindFloor;

  @override
  void initState() {
    super.initState();
    gedungFuture = loadGedungList();
  }

  Future<List<String>> loadGedungList() async {
    final list = await fetchGedungList();
    if (list.isNotEmpty && selectedGedung == null) {
      setState(() {
        selectedGedung = list.first;
      });
    }
    return list;
  }

  Future<List<String>> fetchGedungList() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('sensor').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          DataPageHeader(widget.gender),
          FutureBuilder<List<String>>(
            future: gedungFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final gedungList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GedungDropdown(
                  gedungList: gedungList,
                  selectedGedung: selectedGedung,
                  onChanged: (value) {
                    setState(() {
                      selectedGedung = value;
                    });
                  },
                  gender: widget.gender,
                ),
              );
            },
          ),
          if (selectedGedung != null)
            Expanded(child: _buildToiletAccordionList()),
        ],
      ),
    );
  }

  Widget _buildToiletAccordionList() {
    final okupansiStream =
        FirebaseFirestore.instance
            .collection('sensor')
            .doc(selectedGedung)
            .collection('okupansi')
            .where('gender', isEqualTo: widget.gender)
            .orderBy('lokasi')
            .snapshots();

    final pengunjungStream =
        FirebaseFirestore.instance
            .collection('sensor')
            .doc(selectedGedung)
            .collection('pengunjung')
            .where('gender', isEqualTo: widget.gender)
            .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: okupansiStream,
      builder: (context, okupansiSnapshot) {
        if (!okupansiSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<QuerySnapshot>(
          stream: pengunjungStream,
          builder: (context, pengunjungSnapshot) {
            if (!pengunjungSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final toiletFloorMap = <String, List<ToiletData>>{};
            for (var doc in okupansiSnapshot.data!.docs) {
              final data = ToiletData.fromFirestore(
                doc.data() as Map<String, dynamic>,
              );
              toiletFloorMap.putIfAbsent(data.lokasi, () => []).add(data);
            }

            final visitorFloorMap = <String, String>{};
            for (var doc in pengunjungSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              visitorFloorMap[data['lokasi']] = data['status'];
            }

            return Column(
              children: [
                ToiletAccordionList(
                  toiletFloorMap: toiletFloorMap,
                  visitorFloorMap: visitorFloorMap,
                  gender: widget.gender,
                ),
                RemindMeButton(
                  gender: widget.gender,
                  selectedGedung: selectedGedung,
                  snapshot: okupansiSnapshot.data!,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
