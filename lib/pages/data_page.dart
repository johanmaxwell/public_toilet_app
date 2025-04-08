import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:public_app/models/toilet_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:public_app/utils/string_util.dart';

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
          _buildHeader(),
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
                child: _buildDropdown(gedungList),
              );
            },
          ),
          if (selectedGedung != null)
            Expanded(child: _buildToiletAccordionList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              widget.gender == 'pria'
                  ? [Colors.cyan, Colors.blueAccent]
                  : [Colors.pinkAccent, Colors.pink.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white38,
            ),
            child: Icon(
              widget.gender.toLowerCase() == 'pria' ? Icons.male : Icons.female,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Toilet ${StringUtil.capitalize(widget.gender)}",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<String> gedungList) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              widget.gender == 'pria' ? Colors.blueAccent : Colors.pinkAccent,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGedung,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items:
              gedungList.map((gedung) {
                return DropdownMenuItem<String>(
                  value: gedung,
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 6.0),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                gedungList.indexOf(gedung) == 0
                                    ? Colors.transparent
                                    : Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(StringUtil.snakeToCapitalized(gedung)),
                      ),
                    ),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              selectedGedung = value;
            });
          },
        ),
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
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children:
                        toiletFloorMap.entries.map((entry) {
                          final lokasi = entry.key;
                          final toilets = entry.value;
                          final visitors = visitorFloorMap[lokasi] ?? '0';

                          toilets.sort(
                            (a, b) => int.parse(
                              a.toiletNumber,
                            ).compareTo(int.parse(b.toiletNumber)),
                          );

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                '${StringUtil.snakeToCapitalized(lokasi)} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              collapsedBackgroundColor:
                                  widget.gender == 'pria'
                                      ? Colors.purple.shade200
                                      : Colors.red.shade300,
                              collapsedTextColor: Colors.white,
                              backgroundColor: Colors.white,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 25,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          spacing: 20,
                                          runSpacing: 12,
                                          children:
                                              toilets.map((toilet) {
                                                return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    FaIcon(
                                                      FontAwesomeIcons.toilet,
                                                      color:
                                                          toilet.status ==
                                                                  'occupied'
                                                              ? Colors.red
                                                              : Colors.yellow,
                                                      size: 40,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Toilet ${toilet.toiletNumber}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.people, size: 40),
                                          const SizedBox(width: 7),
                                          Text(
                                            visitors,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
                _buildRemindMeButton(okupansiSnapshot.data!),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRemindMeButton(QuerySnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor:
                widget.gender == 'pria'
                    ? Colors.purpleAccent
                    : Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => _showRemindMePopup(snapshot),
          child: const Text(
            "Remind Me",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showRemindMePopup(QuerySnapshot snapshot) {
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
                          onPressed: () {
                            if (selectedToilet != null) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Reminder set for ${StringUtil.snakeToCapitalized(selectedToilet!)}",
                                  ),
                                ),
                              );
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
